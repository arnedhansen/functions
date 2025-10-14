function mode = askRunMode()
%ASKRUNMODE  Popup to choose whether to process all subjects or only new ones.
% Returns:
%   mode = 'all'  -> process all subjects
%   mode = 'new'  -> process only subjects without saved outputs

    try
        choice = questdlg('Process all subjects or only new ones?', ...
                          'Run mode', ...
                          'All subjects', 'Only new', 'Only new');
        if isempty(choice)
            mode = 'new';
        elseif strcmpi(choice,'All subjects')
            mode = 'all';
            clc
            disp(upper('processing all subjects...'));
        else
            mode = 'new';
            clc
            disp(upper('only processing new subjects...'));
        end
    catch
        % Fallback for headless/CLI sessions (no desktop)
        txt = input('Process all subjects? [y/N]: ','s');
        mode = ternary(strcmpi(strtrim(txt),'y'),'all','new');
    end
end

function out = ternary(cond,a,b)
    if cond, out = a; else, out = b; end
end