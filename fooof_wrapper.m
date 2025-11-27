
function fooof_results = fooof_wrapper(freqs, powspec, f_range, settings, return_model)
% fooof_wrapper.m – call Python fooof_bridge.run_fooof from MATLAB
%
% Usage:
%   fooof_results = fooof_wrapper(freqs, powspec, [fmin fmax], settings, true);

    if nargin < 5
        return_model = true; %#ok<NASGU>  % kept for API compatibility
    end
    if nargin < 4 || isempty(settings)
        settings = struct();
    end

    % Ensure column vectors
    freqs   = freqs(:);
    powspec = powspec(:);

    % MATLAB numeric row -> Python list
    freqs_py   = py.list(freqs.');      % 1×N
    powspec_py = py.list(powspec.');    % 1×N

    % Frequency range as [fmin, fmax]
    fmin = min(f_range);
    fmax = max(f_range);
    f_range_py = py.list([fmin, fmax]);

    % MATLAB struct -> Python dict for FOOOF settings
    settings_py = py.dict();
    s_fields = fieldnames(settings);
    for i = 1:numel(s_fields)
        key = s_fields{i};
        val = settings.(key);

        if islogical(val)
            settings_py{key} = py.bool(val);

        elseif isnumeric(val) && isscalar(val)
            settings_py{key} = val;

        elseif ischar(val) || isstring(val)
            settings_py{key} = char(val);

        elseif isnumeric(val) && ~isscalar(val)
            settings_py{key} = py.list(val(:).');

        else
            % Fallback – pass through as-is
            settings_py{key} = val;
        end
    end

    % Import our helper module
    bridge = py.importlib.import_module('fooof_bridge');

    % Call run_fooof(freqs, powspec, f_range, settings, return_model)
    fooof_results = bridge.run_fooof( ...
        freqs_py, ...
        powspec_py, ...
        f_range_py, ...
        settings_py, ...
        py.bool(true));
end
