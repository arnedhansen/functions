function sizes(varargin)

for i = 1:nargin
    name = inputname(i);
    val  = varargin{i};
    sz   = size(val);

    % Format size as e.g. "1x1" or "120x64"
    szStr = sprintf('%dx', sz);
    szStr = szStr(1:end-1); % remove last 'x'

    % Determine class
    cls = class(val);

    % Create value preview
    if isnumeric(val) || islogical(val)
        if isscalar(val)
            valStr = num2str(val);
        elseif isvector(val) && numel(val) <= 5
            valStr = ['[' num2str(val) ']'];
        else
            valStr = '';
        end
    elseif isstruct(val)
        valStr = '';
    else
        valStr = '';
    end

    % Print
    if isempty(valStr)
        fprintf('%s: %s %s\n', name, szStr, cls);
    else
        fprintf('%s: %s (%s %s)\n', name, valStr, szStr, cls);
    end
end

end
