function init_toolboxes(doInit)
% INIT_TOOLBOXES  Add EEGLAB and FieldTrip to path and initialize.
%
% Syntax:
%   init_toolboxes(doInit)
%
% Input:
%   doInit  - (logical/numeric) If true, add EEGLAB and FieldTrip and run ft_defaults.
%             If false, only display a skip message.
%
% Required Functions:
%   - addEEGLab
if doInit
    clc
    disp(upper('adding eeglab functions...'))
    addEEGLab
    clc
    disp(upper('initializing FieldTrip...'))
    if ispc
        addpath('W:\Students\Arne\toolboxes\fieldtrip-20250928');
    else
        addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/fieldtrip-20250928');
    end
    ft_defaults
else
    clc
    disp(upper('skipping eeglab and fieldtrip initialization...'))
end
end
