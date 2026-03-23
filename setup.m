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
%   - init_toolboxes
%   - get_cva_data_root
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

%% CVA
if strcmp(projectNameNorm, 'CVA')
    colors = color_def('CVA');
    headmodel = [];

    init_toolboxes(initToolboxes);

    if ispc
        cvaRoot = fullfile('C:\Users\Administrator\Documents\GitHub\CVA');
    else
        cvaRoot = fullfile('/Users', 'Arne', 'Documents', 'GitHub', 'CVA');
    end
    if ~isfolder(cvaRoot)
        error('CVA repository not found at: %s', cvaRoot);
    end
    addpath(genpath(cvaRoot));

    path = resolve_cva_paths(cvaRoot);

    if ispc
        headmodelPath = fullfile('W:\Students\Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
    else
        headmodelPath = fullfile('/Volumes/g_psyplafor_methlab$/Students/Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
    end
    if exist(headmodelPath, 'file') == 2
        headmodel = load(headmodelPath);
    end

    subjects = discover_cva_subjects(path.eeg_raw);
    return;
end

%% AOI
if strcmp(projectNameNorm, 'AOI')
    colors = color_def('AOI');
    headmodel = [];

    init_toolboxes(initToolboxes);

    if ispc
        aoiRoot = fullfile('C:\Users\Administrator\Documents\GitHub\AOI');
    else
        aoiRoot = fullfile('/Users', 'Arne', 'Documents', 'GitHub', 'AOI');
    end
    if ~isfolder(aoiRoot)
        error('AOI repository not found at: %s', aoiRoot);
    end
    addpath(genpath(aoiRoot));

    path = resolve_aoi_paths(aoiRoot);

    if ispc
        headmodelPath = fullfile('W:\Students\Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
    else
        headmodelPath = fullfile('/Volumes/g_psyplafor_methlab$/Students/Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
    end
    if exist(headmodelPath, 'file') == 2
        headmodel = load(headmodelPath);
    end

    subjects = discover_aoi_subjects(path);
    return;
end

%% Generic
% Clear environment (keep inputs)
clearvars -except projectName initToolboxes;

init_toolboxes(initToolboxes);

colors = color_def(projectName);

if ispc
    headmodelPath = fullfile('W:\Students\Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
else
    headmodelPath = fullfile('/Volumes/g_psyplafor_methlab$/Students/Arne', 'toolboxes', 'headmodel', 'layANThead.mat');
end
if exist(headmodelPath, 'file') == 2
    headmodel = load(headmodelPath);
else
    headmodel = [];
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

%% CVA
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

function paths = resolve_cva_paths(cvaRoot) %#ok<INUSD>
dataRoot = get_cva_data_root();

paths = struct();
paths.data_root = dataRoot;
% LEMON preprocessed .set files are input; CVA preprocessing writes to EEG/EEG-preprocessed
paths.eeg_raw  = fullfile(dataRoot, 'LEMON', 'EEG', 'EEG-preprocessed');
paths.mri_raw  = fullfile(dataRoot, 'LEMON', 'MRI', 'MRI-raw');
paths.demo     = fullfile(dataRoot, 'LEMON', 'demographics', 'Participants_MPILMBB_LEMON.csv');
paths.eeg_proc = fullfile(dataRoot, 'LEMON', 'EEG', 'EEG-preprocessed');
paths.mri_proc = fullfile(dataRoot, 'LEMON', 'MRI', 'MRI-preprocessed');
paths.eeg_fex  = fullfile(dataRoot, 'LEMON', 'EEG', 'EEG-features');
paths.mri_fex  = fullfile(dataRoot, 'LEMON', 'MRI', 'MRI-features');
paths.demo_fex = fullfile(dataRoot, 'LEMON', 'demographics');
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

%% AOI
function paths = resolve_aoi_paths(aoiRoot)
if ispc
    baseStudents = 'W:\Students\Arne';
else
    baseStudents = '/Volumes/g_psyplafor_methlab$/Students/Arne';
end

paths = struct();
paths.repo = aoiRoot;
paths.functions = fullfile(fileparts(aoiRoot), 'functions');
paths.aoi_root = fullfile(baseStudents, 'AOI');
paths.aoi_data = fullfile(paths.aoi_root, 'data');
paths.aoi_features = fullfile(paths.aoi_data, 'features');
paths.aoi_tables = fullfile(paths.aoi_data, 'tables');
paths.aoi_stats = fullfile(paths.aoi_data, 'stats');
paths.aoi_multiverse = fullfile(paths.aoi_data, 'multiverse');
paths.aoi_figures = fullfile(paths.aoi_root, 'figures');

paths.aoc_root = fullfile(baseStudents, 'AOC');
paths.aoc_data = fullfile(paths.aoc_root, 'data');
paths.aoc_features = fullfile(paths.aoc_data, 'features');
paths.aoc_merged = fullfile(paths.aoc_data, 'merged');
paths.aoc_multiverse = fullfile(paths.aoc_data, 'multiverse');
paths.vp_table = '/Volumes/g_psyplafor_methlab$/VP/OCC/AOC/AOC_VPs.xlsx';

fields = fieldnames(paths);
for i = 1:numel(fields)
    p = paths.(fields{i});
    if ischar(p) && ~contains(p, '.xlsx') && ~contains(p, '.csv') && ~isfolder(p)
        try
            mkdir(p);
        catch
        end
    end
end
end

function subjects = discover_aoi_subjects(paths)
subjectDir = '';
if isfield(paths, 'aoi_features') && isfolder(paths.aoi_features)
    subjectDir = paths.aoi_features;
end
if isempty(subjectDir) || ~isfolder(subjectDir)
    if isfield(paths, 'aoc_features') && isfolder(paths.aoc_features)
        subjectDir = paths.aoc_features;
    end
end

if isempty(subjectDir) || ~isfolder(subjectDir)
    subjects = {};
    return;
end

dirs = dir(subjectDir);
folders = dirs([dirs.isdir] & ~ismember({dirs.name}, {'.', '..'}));
subjects = {folders.name};
end