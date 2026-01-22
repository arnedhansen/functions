function log_error(scriptName, subjectID, subjectIdx, totalSubjects, ME, logDir)
%LOG_ERROR Logs error messages with full details to a file
%   log_error(scriptName, subjectID, subjectIdx, totalSubjects, ME, logDir)
%
%   Inputs:
%   - scriptName: Name of the script where error occurred
%   - subjectID: Subject ID/name (string or number)
%   - subjectIdx: Current iteration index in the loop
%   - totalSubjects: Total number of subjects
%   - ME: MATLAB exception object (MException)
%   - logDir: Directory where log files should be saved
%
%   Creates a log file named: <scriptName>_errors_<YYYYMMDD>.log

    % Ensure log directory exists
    if ~exist(logDir, 'dir')
        mkdir(logDir);
    end
    
    % Create log filename with date
    logFileName = sprintf('%s_errors_%s.log', scriptName, datestr(now, 'YYYYmmdd'));
    logFilePath = fullfile(logDir, logFileName);
    
    % Open log file for appending
    fid = fopen(logFilePath, 'a');
    if fid == -1
        warning('Could not open log file: %s', logFilePath);
        return;
    end
    
    try
        % Write error header
        fprintf(fid, '\n%s\n', repmat('=', 1, 80));
        fprintf(fid, 'ERROR LOG ENTRY\n');
        fprintf(fid, 'Timestamp: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid, 'Script: %s\n', scriptName);
        fprintf(fid, 'Subject ID: %s\n', num2str(subjectID));
        fprintf(fid, 'Subject Iteration: %d / %d\n', subjectIdx, totalSubjects);
        fprintf(fid, '%s\n', repmat('-', 1, 80));
        
        % Write error message
        fprintf(fid, 'Error Message:\n%s\n\n', ME.message);
        
        % Write stack trace
        if ~isempty(ME.stack)
            fprintf(fid, 'Stack Trace:\n');
            for k = 1:length(ME.stack)
                fprintf(fid, '  File: %s\n', ME.stack(k).file);
                fprintf(fid, '  Function: %s\n', ME.stack(k).name);
                fprintf(fid, '  Line: %d\n\n', ME.stack(k).line);
            end
        end
        
        % Write full error report
        fprintf(fid, 'Full Error Report:\n');
        errorReport = getReport(ME, 'extended', 'hyperlinks', 'off');
        fprintf(fid, '%s\n', errorReport);
        fprintf(fid, '%s\n\n', repmat('=', 1, 80));
        
    catch logErr
        warning('Error while writing to log file: %s', logErr.message);
    end
    
    % Close file
    fclose(fid);
    
    % Also print to console
    fprintf('\n[ERROR] Subject %s (iteration %d/%d) in %s:\n', ...
        num2str(subjectID), subjectIdx, totalSubjects, scriptName);
    fprintf('  Error: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('  Location: %s (line %d)\n', ME.stack(1).file, ME.stack(1).line);
    end
    fprintf('  Full log saved to: %s\n', logFilePath);
end
