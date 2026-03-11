%% setup - MATLAB Data Processing Environment for Arne's Projects
%
% Syntax:
%   setup()
%   [subjects, path, colors, headmodel] = setup(projectName)
%   [subjects, path, colors, headmodel] = setup(projectName, initToolboxes)
%
% Input:
%   projectName    - (char, optional) Name of the project folder containing
%                    subject data.
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

% No-argument mode: return placeholders without side effects.
if nargin == 0
    subjects = {};
    path = '';
    colors = struct();
    headmodel = [];
    return;
end

% Handle optional input
if nargin < 2 || isempty(initToolboxes)
    initToolboxes = 1; % default: load EEGLAB + FieldTrip
end

projectNameChar = char(string(projectName));
projectNameNorm = upper(strtrim(projectNameChar));

%%%%%%%%%%%% CVA-specific setup branch
if strcmp(projectNameNorm, 'CVA')
    colors = color_def('CVA');
    headmodel = [];

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

    if ispc == 1
        cvaRoot = fullfile('C:\Users\Administrator\Documents\GitHub\CVA');
    else
        cvaRoot = fullfile('/Users', 'Arne', 'Documents', 'GitHub', 'CVA');
    end
    if ~isfolder(cvaRoot)
        error('CVA repository not found at: %s', cvaRoot);
    end
    addpath(genpath(cvaRoot));

    path = resolve_cva_paths(cvaRoot);

    if ispc == 1
        headmodelPath = 'W:\Students\Arne\toolboxes\headmodel\layANThead.mat';
    else
        headmodelPath = '/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/headmodel/layANThead.mat';
    end
    if exist(headmodelPath, 'file') == 2
        headmodel = load(headmodelPath);
    end

    subjects = discover_cva_subjects(path.eeg_raw);
    return;
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

% Load headmodel
if ispc == 1
    headmodel = load('W:\Students\Arne\toolboxes\headmodel\layANThead.mat');
else
    headmodel = load('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/headmodel/layANThead.mat');
end

% Set base path and get subjects
if ispc == 1
    baseDir = 'W:\Students\Arne\';
else
    baseDir = '/Volumes/g_psyplafor_methlab$/Students/Arne/';
end

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

function subjects = discover_cva_subjects(eegRawDir)
if ~isfolder(eegRawDir)
    error('CVA EEG directory not found: %s', eegRawDir);
end

listing  = dir(fullfile(eegRawDir, 'sub-*'));
subjects = {listing([listing.isdir]).name};
subjects = sort(subjects);

subjects = apply_cva_subject_overrides(subjects);

fprintf('Loaded CVA subjects: %d\n', numel(subjects));
end

function paths = resolve_cva_paths(cvaRoot)
if exist('resolve_data_root', 'file') == 2
    dataRoot = resolve_data_root();
else
    if ispc
        candidates = { ...
            'W:\Students\Arne\CVA\data', ...
            fullfile(cvaRoot, 'data') ...
        };
    else
        candidates = { ...
            '/Volumes/g_psyplafor_methlab$/Students/Arne/CVA/data', ...
            fullfile(cvaRoot, 'data') ...
        };
    end
    dataRoot = '';
    for i = 1:numel(candidates)
        if exist(candidates{i}, 'dir')
            dataRoot = candidates{i};
            break;
        end
    end
    if isempty(dataRoot)
        error('CVA data root not found. Set CVA_DATA_ROOT or create CVA/data.');
    end
end

paths = struct();
paths.eeg_raw  = fullfile(dataRoot, 'EEG', 'EEG-raw');
paths.mri_raw  = fullfile(dataRoot, 'MRI', 'MRI-raw');
paths.demo     = fullfile(dataRoot, 'demographics', 'Participants_MPILMBB_LEMON.csv');
paths.eeg_proc = fullfile(dataRoot, 'EEG', 'EEG-preprocessed');
paths.mri_proc = fullfile(dataRoot, 'MRI', 'MRI-preprocessed');
paths.eeg_fex  = fullfile(dataRoot, 'EEG', 'EEG-features');
paths.mri_fex  = fullfile(dataRoot, 'MRI', 'MRI-features');
paths.demo_fex = fullfile(dataRoot, 'demographics');
paths.master   = dataRoot;
paths.fex      = paths.master; % legacy alias for scripts expecting paths.fex
paths.stats    = fullfile(dataRoot, 'stats');
paths.figures  = fullfile(fileparts(dataRoot), 'figures');
paths.logs     = fullfile(dataRoot, 'logs');

fields = fieldnames(paths);
for i = 1:numel(fields)
    d = paths.(fields{i});
    if ~contains(d, '.csv') && ~exist(d, 'dir')
        mkdir(d);
    end
end
end

function outSubjects = apply_cva_subject_overrides(allSubjects)
overrideSubjects = {};

envSubjects = strtrim(getenv('CVA_SUBJECTS'));
if ~isempty(envSubjects)
    tokens = regexp(envSubjects, '[,;\s]+', 'split');
    tokens = tokens(~cellfun(@isempty, tokens));
    overrideSubjects = normalize_cva_subject_list(tokens);
elseif ~isempty(strtrim(getenv('CVA_SUBJECT')))
    overrideSubjects = normalize_cva_subject_list(strtrim(getenv('CVA_SUBJECT')));
end

if isempty(overrideSubjects)
    outSubjects = allSubjects;
    return;
end

foundMask = ismember(overrideSubjects, allSubjects);
found = overrideSubjects(foundMask);
missing = overrideSubjects(~foundMask);

if ~isempty(missing)
    warning('Requested CVA subjects not found and skipped: %s', strjoin(missing, ', '));
end
if isempty(found)
    error('No requested CVA subjects were found in data directory.');
end

outSubjects = found;
end

function out = normalize_cva_subject_list(in)
out = {};
if isempty(in)
    return;
end

if isstring(in)
    in = cellstr(in);
elseif ischar(in)
    in = {in};
elseif ~iscell(in)
    error('CVA subject override must be char, string, cellstr, or string array.');
end

tmp = cell(1, numel(in));
for i = 1:numel(in)
    sid = strtrim(string(in{i}));
    if sid == ""
        continue;
    end
    if ~startsWith(sid, "sub-")
        sid = "sub-" + sid;
    end
    tmp{i} = char(sid);
end

tmp = tmp(~cellfun(@isempty, tmp));
out = unique(tmp, 'stable');
end