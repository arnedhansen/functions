% Helper to compute per-trial ROI power within a freq band.
% Includes robust filtering to suppress pathological numeric outliers.
function P = bandpower_trials(powobj, chanIdx, frq, band)
if any(isnan(band))
    P = NaN(size(powobj.powspctrm,1),1);
    return
end
fmask = (frq >= band(1)) & (frq <= band(2));
if ~any(fmask)
    P = NaN(size(powobj.powspctrm,1),1);
    return
end
% Average over channels (ROI) and selected frequencies, per trial.
% A hard plausibility bound and robust 3*IQR clipping are applied trial-wise.
S = powobj.powspctrm(:, chanIdx, fmask);             % [rpt x chan x freq]
nTrials = size(S, 1);
P = NaN(nTrials, 1);
for tr = 1:nTrials
    x = reshape(S(tr, :, :), [], 1);
    x = x(isfinite(x));
    x = x(abs(x) <= 1e4); % suppress catastrophic scale artifacts
    if numel(x) >= 8
        q1 = prctile(x, 25);
        q3 = prctile(x, 75);
        iqr_v = q3 - q1;
        if isfinite(iqr_v) && iqr_v > 0
            lo = q1 - 3 * iqr_v;
            hi = q3 + 3 * iqr_v;
            x = x(x >= lo & x <= hi);
        end
    end
    if ~isempty(x)
        P(tr) = mean(x, 'omitnan');
    end
end
end