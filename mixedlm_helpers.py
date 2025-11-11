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

def wald_table_for_terms(res, term_names):
    """
    Joint Wald tests for multi-df terms in a MixedLM.
    term_names: list of lists, each inner list contains parameter name substrings
                to group (e.g., all dummies for C(Condition) or all interaction terms).
    Returns DataFrame with chi^2 and p for each set.
    """
    rows = []
    beta = res.params
    V    = res.cov_params()
    for label, name_list in term_names:
        idx = [i for i, n in enumerate(beta.index) if any(s in n for s in name_list)]
        if len(idx) == 0:
            rows.append([label, np.nan, np.nan, np.nan])
            continue
        b = beta.values[idx]
        Vsub = V.values[np.ix_(idx, idx)]
        # H0: all selected coefficients == 0
        # Wald chi2 = b' V^-1 b
        try:
            Vinv = np.linalg.inv(Vsub)
            chi2_val = float(b.T @ Vinv @ b)
            df = len(idx)
            p = 1.0 - chi2.cdf(chi2_val, df)
        except np.linalg.LinAlgError:
            chi2_val, df, p = np.nan, len(idx), np.nan
        rows.append([label, df, chi2_val, p])
    return pd.DataFrame(rows, columns=["Term", "df", "Wald_Chi2", "p"])

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
