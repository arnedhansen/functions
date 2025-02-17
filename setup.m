%% Function to set up data processing for any project

function [subjects, path, colors] = setup(projectName)
    % Clear environment
    clearvars -except projectName;
    addpath('/Users/Arne/Documents/matlabtools/eeglab2024.2');
    eeglab;
    clc;
    close all;

    % Load colors
    colors = color_def(projectName);

    % Set the base path according to the provided project name
    baseDir = '/Volumes/methlab/Students/Arne/';
    path = fullfile(baseDir, projectName, 'data/features/');

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
    disp(subjects);
end
