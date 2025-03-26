%% Function to set up data processing for any project

function [subjects, path, colors, headmodel] = setup(projectName)
% Clear environment
clearvars -except projectName;

% Add EEG Lab functions
addEEGLab

% Load colors
colors = color_def(projectName);

% Load headmodel
if ispc == 1
    headmodel = load('W:\Students\Arne\MA\headmodel\ant128lay.mat');
else
    headmodel = load('/Volumes/methlab/Students/Arne/MA/headmodel/ant128lay.mat');
end

% Set the base path according to the provided project name
if ispc == 1
    baseDir = 'W:\Students\Arne\';
    path = strcat(baseDir, projectName, 'data\features\');
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
disp('Loaded subjects:');
disp(subjects(:));
end
