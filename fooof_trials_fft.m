% Trial-wise FOOOF on ROI-averaged FFT spectra (FieldTrip freq struct with keeptrials='yes')
function out = fooof_trials_fft(powobj, chanIdx, freq_range, settings, alpha_range)
    % Inputs:
    %   powobj     : FieldTrip freq struct, powspctrm [rpt x chan x freq], freq 1 x F
    %   chanIdx    : indices of ROI channels; if empty, all channels are used
    %   freq_range : [fmin fmax] fit band (default [3 30])
    %   settings   : FOOOF settings (peak_width_limits, aperiodic_mode, etc.)
    %   alpha_range: [flow fhigh] for selecting alpha peak (default [8 14])
    %
    % Output fields (nTrials x 1 vectors):
    %   out.offset, out.exponent, out.alpha_cf, out.alpha_pw, out.alpha_bw, out.r2, out.n_peaks

    if nargin < 3 || isempty(freq_range),  freq_range  = [3 30];  end
    if nargin < 4 || isempty(settings),    settings    = struct(); end
    if nargin < 5 || isempty(alpha_range), alpha_range = [8 14];  end
    if isempty(chanIdx), chanIdx = 1:numel(powobj.label); end

    freqs = powobj.freq(:)';                           % 1 x F
    fmask = freqs >= freq_range(1) & freqs <= freq_range(2);
    if ~any(fmask), error('fooof_trials_fft: freq_range outside available frequencies.'); end
    fu = freqs(fmask); df = diff(fu);
    if isempty(df), error('fooof_trials_fft: too few frequency bins within freq_range.'); end
    tol = 1e-4 * median(df);
    if max(abs(df - median(df))) > tol, fu_target = fu(1):median(df):fu(end); else, fu_target = fu; end

    if ~isfield(settings,'peak_width_limits'), settings.peak_width_limits = [2 12]; end
    if ~isfield(settings,'aperiodic_mode'),    settings.aperiodic_mode    = 'fixed'; end
    if ~isfield(settings,'verbose'),           settings.verbose           = false;   end

    nT = size(powobj.powspctrm, 1);
    out.offset   = nan(nT,1);
    out.exponent = nan(nT,1);
    out.alpha_cf = nan(nT,1);
    out.alpha_pw = nan(nT,1);
    out.alpha_bw = nan(nT,1);
    out.r2       = nan(nT,1);
    out.n_peaks  = nan(nT,1);

    for t = 1:nT
        % ROI-average the trial spectrum
        S = squeeze(mean(powobj.powspctrm(t, chanIdx, :), 2))';   % 1 x F
        S = S(:)';

        % Restrict to freq_range and (if needed) interpolate to uniform grid
        S_sub = S(fmask);
        if numel(fu_target) ~= numel(S_sub)
            S_sub = interp1(fu, S_sub, fu_target, 'linear', 'extrap');
        end

        % Guard: finite & positive
        good = isfinite(S_sub) & (S_sub > 0) & isfinite(fu_target);
        if nnz(good) < 5, continue, end

        f_use = fu_target(good)'; p_use = S_sub(good)';

        % Fit FOOOF
        try
            res = fooof(f_use, p_use, [min(f_use) max(f_use)], settings, true);
        catch
            continue
        end

        % Aperiodic
        [off, expn] = parse_aperiodic(res);
        out.offset(t)   = off;
        out.exponent(t) = expn;

        % Peaks → choose alpha in alpha_range (largest by power)
        P = parse_peaks(res); out.n_peaks(t) = size(P,1);
        if ~isempty(P)
            amask = P(:,1) >= alpha_range(1) & P(:,1) <= alpha_range(2);
            if any(amask)
                Pa = P(amask,:);
                [~, imax] = max(Pa(:,2));
                out.alpha_cf(t) = Pa(imax,1);
                out.alpha_pw(t) = Pa(imax,2);
                out.alpha_bw(t) = Pa(imax,3);
            end
        end

        % R^2 if available
        if isstruct(res)
            if isfield(res,'r_squared'), out.r2(t) = res.r_squared; end
            if isfield(res,'r2'),        out.r2(t) = res.r2;        end
        end
    end
end

% --- local helpers ---

function [off, expn] = parse_aperiodic(res)
    off = NaN; expn = NaN;
    try
        if isfield(res, 'background_params'), v = res.background_params; off = v(1); expn = v(2); return, end
        if isfield(res, 'aperiodic_params'),  v = res.aperiodic_params;  off = v(1); expn = v(2); return, end
        if isfield(res, 'ap_params'),         v = res.ap_params;         off = v(1); expn = v(2); return, end
        if isfield(res,'ap_fit') && isfield(res,'freqs')
            y = res.ap_fit(:); x = res.freqs(:);
            good = isfinite(x) & isfinite(y) & (x > 0) & (y > 0);
            if nnz(good) > 5
                X = [ones(nnz(good),1) log10(x(good))];
                b = X \ log10(y(good));
                off = b(1); expn = -b(2);
            end
        end
    catch
    end
end

function P = parse_peaks(res)
    P = [];
    try
        if isfield(res,'peak_params'),      P = res.peak_params;      end
        if isempty(P) && isfield(res,'gaussian_params'), P = res.gaussian_params; end
        if isempty(P) && isfield(res,'peaks'),           P = res.peaks;           end
        if ~isempty(P) && size(P,2) >= 3, P = double(P(:,1:3)); else, P = []; end
    catch
        P = [];
    end
end
