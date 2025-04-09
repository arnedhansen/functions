function runInFunction(scriptPath)
%RUNINFUNCTION Runs a MATLAB script in an isolated function workspace.
%
%   RUNINFUNCTION(SCRIPTPATH) executes the MATLAB script specified by
%   SCRIPTPATH inside a function, creating an isolated workspace. This 
%   prevents the script from affecting the variables or workspace of the 
%   calling function or script (e.g., avoids 'clear', 'cd', etc. impacting 
%   your master script).
%
%   This is especially useful when running multiple analysis scripts in a 
%   loop, where individual scripts might include destructive commands such
%   as 'clear' or 'clc'.
%
%   Input:
%       scriptPath - Full path to a MATLAB script (.m file) as a character 
%                    vector or string.
%
%   Example:
%       runInFunction('/Users/Arne/Documents/GitHub/AOC/1_preprocessing/3_merge/AOC_mergeData.m')
%
%   If an error occurs during execution of the script, the function will
%   throw an error with the script path and the corresponding message.
%
    try
        run(scriptPath);
    catch ME
        error('Error in %s: %s', scriptPath, ME.message);
    end
end
