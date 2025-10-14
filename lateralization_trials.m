% Helper to compute per-trial lateralization with ridge or log-ratio
function [LI, Rsum_typ] = lateralization_trials(powobj, leftLab, rightLab, frq, band, ridgeFrac, epsP)
    if any(isnan(band))
        LI = NaN(size(powobj.powspctrm,1),1);
        Rsum_typ = NaN;
        return
    end
    fmask = (frq >= band(1)) & (frq <= band(2));
    left_idx  = find(ismember(powobj.label, leftLab));
    right_idx = find(ismember(powobj.label, rightLab));
    if isempty(left_idx) || isempty(right_idx) || ~any(fmask)
        LI = NaN(size(powobj.powspctrm,1),1);
        Rsum_typ = NaN; return
    end
    S  = powobj.powspctrm;                                % [rpt x chan x freq]
    L  = squeeze(mean(S(:, left_idx,  fmask),  2));       % [rpt x freqMask]
    R  = squeeze(mean(S(:, right_idx, fmask),  2));       % [rpt x freqMask]
    Lp = mean(L, 2);                                      % [rpt x 1]
    Rp = mean(R, 2);                                      % [rpt x 1]
    Rsum = Rp + Lp;
    Rsum_typ = median(Rsum(~isnan(Rsum)));
    lam = ridgeFrac * max(Rsum_typ, epsP);
    LI = (Rp - Lp) ./ (Rsum + lam);
end