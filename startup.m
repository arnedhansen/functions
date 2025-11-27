%% Startup MATLAB Arne
clear
clc
close all
if ~ispc
    restoredefaultpath
    disp(upper('starting up matlab...'))

    %% Initialize Python
    % Force MATLAB's Python bridge to use the conda python env
    try
        pyenv('Version', '/opt/anaconda3/envs/matlab_fooof/bin/python', ...
              'ExecutionMode', 'OutOfProcess');
    catch ME
        warning('Could not set pyenv: %s', ME.message);
    end

    %% Connect to server METHLAB
    disp(upper('connecting to servers...'))
    serverPath = 'smb://idnas37.d.uzh.ch/g_psyplafor_methlab$';
    appleScriptCmd = sprintf('osascript -e "mount volume \\"%s\\""', serverPath);
    [status, cmdout] = system(appleScriptCmd);
    if status == 0
        disp(upper('Server ''methlab'' connected successfully!'));
    else
        disp(['Failed to connect to server methlab_data: ', cmdout]);
    end

    %% Connect to server METHLAB_DATA
    serverPath = 'smb://idnas37.d.uzh.ch/g_psyplafor_methlab_data$';
    appleScriptCmd = sprintf('osascript -e "mount volume \\"%s\\""', serverPath);
    [status, cmdout] = system(appleScriptCmd);
    if status == 0
        disp(upper('Server ''methlab_data'' connected successfully!'));
    else
        disp(['Failed to connect to server methlab_data: ', cmdout]);
    end

    %% Add paths for toolboxes and functions
    disp(upper('addin paths to toolboxes and functions...'));
    % Toolboxes
    addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/');
    % Explicitly add shadedErrorBar
    addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/shadedErrorBar');
    % FOOOF with python for MATLAB
    addpath(genpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/fooof_mat-main'));
    % color maps
    addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/colormaps');
    % Custom functions from local github folder
    addpath('/Users/Arne/Documents/GitHub/functions');

    %% Change directory to scripts
    cd('/Users/Arne/Documents/GitHub/')
    clear

    %% Get screen size
    set(0,'units','pixels')
    %get(0, 'ScreenSize')

    %%
    %clc
    disp(upper('matlab is ready...'))
elseif ispc
    disp(upper('STARTUP FOR WINDOWS PC ON METHLAB SERVER...'))
    cd('C:\Users\Administrator\Documents\MATLAB\')
    startup
end