% Per-trial dB baseline between matched trials (late vs baseline)
function pow_db = per_trial_db(pow_win, pow_base)
    % expects powspctrm as [rpt x chan x freq] with same #rpt and freq grid
    epsv = 1e-12;
    B = pow_base.powspctrm;
    W = pow_win.powspctrm;
    if size(B,1) ~= size(W,1) || any(pow_base.freq(:) ~= pow_win.freq(:))
        error('per_trial_db: trial count or frequency grid mismatch.');
    end
    ratio = (W + epsv) ./ (B + epsv);
    pow_db = pow_win;
    pow_db.powspctrm = 10 * log10(ratio);
end
