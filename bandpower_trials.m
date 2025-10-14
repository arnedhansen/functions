% Helper to compute per-trial ROI power within a freq band
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
% average over channels (ROI) and over selected freqs, per trial
S = powobj.powspctrm(:, chanIdx, :);                 % [rpt x chan x freq]
S = squeeze(mean(S, 2));                              % [rpt x freq]
P = mean(S(:, fmask), 2);                             % [rpt x 1]
end