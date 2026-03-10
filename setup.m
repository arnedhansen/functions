%% setup - MATLAB Data Processing Environment for Arne's Projects
%
% Syntax:
%   [subjects, path, colors, headmodel] = setup(projectName)
%   [subjects, path, colors, headmodel] = setup(projectName, initToolboxes)
%
% Input:
%   projectName    - (char) Name of the project folder containing subject data.
%   initToolboxes  - (logical / numeric) Flag indicating whether to initialise
%                    EEGLAB and FieldTrip. Default = 1.
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
function [subjects, path, colors, headmodel] = setup(projectName, initToolboxes)

% Handle optional input
if nargin < 2 || isempty(initToolboxes)
    initToolboxes = 1; % default: load EEGLAB + FieldTrip
end

% Clear environment (keep inputs)
clearvars -except projectName initToolboxes;

% Add EEG Lab functions and initialise FieldTrip only if requested
if initToolboxes
    clc
    disp(upper('adding eeglab functions...'))
    addEEGLab
    clc
    disp(upper('initializing FieldTrip...'))
    if ispc == 1
        addpath('W:\Students\Arne\toolboxes\fieldtrip-20250928');
    else
        addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/fieldtrip-20250928');
    end
    ft_defaults
else
    clc
    disp(upper('skipping eeglab and fieldtrip initialization...'))
end

% Load colors
colors = color_def(projectName);

% --- CVA: no ANT headmodel needed (MRI-based, handled via CAT12/SPM) ---
if strcmpi(projectName, 'CVA')
    headmodel = [];

    % SPM12 path (platform-specific)
    if ispc == 1
        spmRoot = 'W:\Students\Arne\toolboxes\spm12';
    else
        spmRoot = '/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/spm12';
    end
    if ~isfolder(spmRoot)
        error('SPM12 folder not found: %s', spmRoot);
    end
    addpath(spmRoot);

    % Initialize SPM and verify CAT12 availability
    if ~exist('spm', 'file')
        error('SPM12 is not available on MATLAB path after addpath.');
    end
    spm('defaults', 'fmri');
    spm_jobman('initcfg');
    if ~exist('cat12', 'file')
        error('CAT12 not found. Install in spm12/toolbox/cat12 and restart MATLAB.');
    end
else
    if ispc == 1
        headmodel = load('W:\Students\Arne\toolboxes\headmodel\layANThead.mat');
    else
        headmodel = load('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/headmodel/layANThead.mat');
    end
end

% Set base path and get subjects
if ispc == 1
    baseDir = 'W:\Students\Arne\';
else
    baseDir = '/Volumes/g_psyplafor_methlab$/Students/Arne/';
end

% --- CVA: different folder structure and subject ID format ---
if strcmpi(projectName, 'CVA')

    path = fullfile(baseDir, projectName, 'data', 'features');

    % Subjects are identified from EEG data folder (sub-XXXXXX format)
    eegDir = fullfile(baseDir, projectName, 'data', 'EEG');
    if ~isfolder(eegDir)
        error('CVA EEG data folder does not exist: %s', eegDir);
    end
    dirs     = dir(fullfile(eegDir, 'sub-*'));
    folders  = dirs([dirs.isdir]);
    subjects = {folders.name};

    fprintf('Loaded %d CVA subjects (LEMON format).\n', numel(subjects));
    disp(subjects(:));

else
    % --- All other projects: original behaviour unchanged ---
    path = strcat(baseDir, projectName, '\data\features\');
    if ~ispc
        path = fullfile(baseDir, projectName, 'data/features/');
    end

    if ~isfolder(path)
        error('This project path does not exist: %s', path);
    end

    dirs    = dir(path);
    folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
    subjects = {folders.name};

    filteredSubjects = str2double(string(subjects));
    disp('Loaded subjects:');
    disp(filteredSubjects(:));

end
end