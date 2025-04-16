%% setup - Set up data processing environment for EEG projects
%
% Syntax:
%   [subjects, path, colors, headmodel] = setup(projectName)
%
% Description:
%   This function sets up the environment for EEG data processing based on
%   the specified project name. It adds EEGLAB functions to the path, loads 
%   colour definitions, the appropriate head model, and identifies the 
%   subject folders in the project directory.
%
% Input:
%   projectName - (char) Name of the project folder containing subject data.
%
% Output:
%   subjects   - (cell array) Names of subject folders in the data directory.
%   path       - (char) Path to the project's features directory.
%   colors     - (struct) Colour definitions specific to the project.
%   headmodel  - (struct) Loaded head model for EEG data processing.
%
% Notes:
%   - Requires the `color_def` and `addEEGLab` functions to be available 
%     in the MATLAB path.
%
% Example:
%   [subjects, path, colors, ant128lay] = setup('AOC');

function [subjects, path, colors, headmodel] = setup(projectName)
% Clear environment
clearvars -except projectName;

% Add EEG Lab functions
addEEGLab

% Load colors
colors = color_def(projectName);

% Load headmodel
if ispc == 1
    headmodel = load('W:\Students\Arne\toolboxes\headmodel\layANThead.mat');
else
    headmodel = load('/Volumes/methlab/Students/Arne/toolboxes/headmodel/layANThead.mat');
end

% Set the base path according to the provided project name
if ispc == 1
    baseDir = 'W:\Students\Arne\';
    path = strcat(baseDir, projectName, '\data\features\');
else
    baseDir = '/Volumes/methlab/Students/Arne/';
    path = fullfile(baseDir, projectName, 'data/features/');
end

% Check if the path exists
if ~isfolder(path)
    error('The specified project path does not exist: %s', path);
end

% List directories in the selected path
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};

% Display the loaded subjects
filteredSubjects = str2double(string(subjects));
disp('Loaded subjects:');
disp(filteredSubjects(:));
end
