%% setup - MATLAB Data Processing Environment for Arne's Projects
%
% Syntax:
%   [subjects, path, colors, headmodel] = setup(projectName)
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
% Required Functions:
%   - color_def
%   - addEEGLab

function [subjects, path, colors, headmodel] = setup(projectName)
% Clear environment
clearvars -except projectName;

% Add EEG Lab functions
clc
disp(upper('adding eeglab functions...'))
addEEGLab

% Initialize FieldTrip
clc
disp(upper('initializing FieldTrip...'))
if ispc == 1
    addpath('W:\Students\Arne\toolboxes\fieldtrip-20250928');
else
    addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/fieldtrip-20250928');
end
% which ft_defaults
% which ft_warning
ft_defaults

% Load colors
colors = color_def(projectName);

% Load headmodel
if ispc == 1
    headmodel = load('W:\Students\Arne\toolboxes\headmodel\layANThead.mat');
else
    headmodel = load('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/headmodel/layANThead.mat');
end

% Set the base path according to the provided project name
if ispc == 1
    baseDir = 'W:\Students\Arne\';
    path = strcat(baseDir, projectName, '\data\features\');
else
    baseDir = '/Volumes/g_psyplafor_methlab$/Students/Arne/';
    path = fullfile(baseDir, projectName, 'data/features/');
end

% Check if the path exists
if ~isfolder(path)
    error('This project path does not exist: %s', path);
end

% List directories in the selected path
dirs = dir(path);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};
%subjects = subjects(1:10)
%disp('ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED ATTENTION ONLY 10 SUBS LOADED')

% Display the loaded subjects
filteredSubjects = str2double(string(subjects));
disp('Loaded subjects:');
disp(filteredSubjects(:));
end
