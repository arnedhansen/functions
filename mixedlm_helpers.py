import numpy as np
import pandas as pd
from scipy.stats import chi2, norm
import statsmodels.formula.api as smf

def fit_mixedlm(formula, data, group, reml=False, method="lbfgs", maxiter=500):
    m = smf.mixedlm(formula, data=data, groups=data[group], re_formula="1")
    res = m.fit(reml=reml, method=method, maxiter=maxiter, disp=False)
    return res

def drop1_lrt(full_res, reduced_res):
    # Likelihood-ratio test comparing nested mixed models (full vs reduced)
    ll_full = float(getattr(full_res, "llf", np.nan))
    ll_red  = float(getattr(reduced_res, "llf", np.nan))
    df_full = int(getattr(full_res, "df_modelwc", np.nan))
    df_red  = int(getattr(reduced_res, "df_modelwc", np.nan))
    df_diff = df_full - df_red
    LR = 2.0 * (ll_full - ll_red)
    p  = 1.0 - chi2.cdf(LR, df=df_diff if df_diff > 0 else 1)
    return {"LL_full": ll_full, "LL_reduced": ll_red, "df_full": df_full, "df_reduced": df_red,
            "df_diff": df_diff, "LR": LR, "p": p}

def pairwise_condition_contrasts_at_mean_gaze(res, condition_levels, design_prefix="C(Condition)"):
    """
    For a MixedLM with formula: AlphaPower ~ Gaze_c * C(Condition) + (1|ID),
    if Gaze_c is mean-centred, then contrasts across Condition at Gaze_c=0
    depend only on the Condition main-effect dummies.
    We compute estimates, SE, z, p, and Bonferroni-adjusted p.
    """
    beta = res.params
    V    = res.cov_params()

    # Build fixed-effect contrast vectors for mean(Gaze_c)=0
    # Param names like: 'Intercept', 'Gaze_c', 'C(Condition)[T.L2]', 'Gaze_c:C(Condition)[T.L2]', ...
    names = list(beta.index)
    def cvec_for_level(level):
        c = np.zeros(len(names))
        # mean at level L:
        # mu(L) = Intercept + [C(Condition)[T.L]]  (since Gaze_c=0 -> interaction drops)
        c[names.index("Intercept")] = 1.0
        pname = f"{design_prefix}[T.{level}]"
        if pname in names:
            c[names.index(pname)] = 1.0
        return c

    results = []
    for i in range(len(condition_levels)):
        for j in range(i+1, len(condition_levels)):
            g1, g2 = condition_levels[i], condition_levels[j]
            c = cvec_for_level(g2) - cvec_for_level(g1)
            est = float(c @ beta.values)
            se  = float(np.sqrt(c @ V.values @ c))
            z   = est / se if se > 0 else np.nan
            p   = 2.0 * (1.0 - norm.cdf(abs(z))) if np.isfinite(z) else np.nan
            results.append((g1, g2, est, se, z, p))
    out = pd.DataFrame(results, columns=["Group1","Group2","Estimate","SE","z","p"])
    # Bonferroni
    if len(out) > 0:
        m = out.shape[0]
        out["p_adj"] = np.minimum(out["p"] * m, 1.0)
    else:
        out["p_adj"] = out["p"]
    return out

def mixedlm_fixed_effects_to_df(res, task=None, variable=None, model_label=None):
    """
    Extract fixed-effect summaries from a statsmodels result (MixedLM or OLS)
    into a tidy DataFrame: term, beta, SE, z/t, p, CI.
    Optionally annotate with Task / Variable / ModelLabel columns.
    """
    params = res.params

    # Standard errors: try bse, then bse_fe (MixedLM)
    se = getattr(res, "bse", None)
    if se is None and hasattr(res, "bse_fe"):
        se = res.bse_fe
    if se is None:
        # Fallback: no SE available
        se = pd.Series(index=params.index, dtype=float)

    # t/z statistics
    stat = getattr(res, "tvalues", None)
    if stat is None:
        stat = getattr(res, "zvalues", None)
    if stat is None:
        # compute from params / SE if possible
        stat = params / se

    # p-values
    pvals = getattr(res, "pvalues", None)
    if pvals is None:
        from scipy.stats import norm
        pvals = 2.0 * (1.0 - norm.cdf(np.abs(stat)))

    # confidence intervals
    try:
        ci = res.conf_int()
        if isinstance(ci, pd.DataFrame):
            ci.columns = ["ci_low", "ci_high"]
        else:
            ci = pd.DataFrame(ci, index=params.index, columns=["ci_low", "ci_high"])
    except Exception:
        ci = None

    df = pd.DataFrame({
        "Term": params.index,
        "beta": params.values,
        "SE":   se.reindex(params.index).values,
        "stat": stat.reindex(params.index).values,
        "p":    pvals.reindex(params.index).values
    })

    if ci is not None:
        ci = ci.reindex(params.index)
        df["CI_low"]  = ci["ci_low"].values
        df["CI_high"] = ci["ci_high"].values
    else:
        df["CI_low"]  = np.nan
        df["CI_high"] = np.nan

    # Optional annotations
    if task is not None:
        df.insert(0, "Task", task)
    if variable is not None:
        df.insert(1, "DV", variable)
    if model_label is not None:
        df.insert(2, "ModelLabel", model_label)

    return df


def lr_effect_sizes(LR, df_diff, n_obs):
    """
    Likelihood-ratio based effect sizes for nested model comparisons.

    R2_LR = 1 - exp(-LR / n)
    f2_LR = R2_LR / (1 - R2_LR)

    Returns (R2_LR, f2_LR). Uses NaN if inputs are not finite or n<=0.
    """
    import numpy as np

    if (not np.isfinite(LR)) or (LR <= 0) or (not np.isfinite(n_obs)) or (n_obs <= 0):
        return np.nan, np.nan

    R2_LR = 1.0 - np.exp(-LR / n_obs)
    f2_LR = R2_LR / (1.0 - R2_LR) if R2_LR < 1.0 else np.nan
    return R2_LR, f2_LR