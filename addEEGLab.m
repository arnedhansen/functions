function addEEGLab
if ispc == 1
    addpath W:\Students\Arne\toolboxes\eeglab2024.2
else
    addpath /Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/eeglab2024.2
    %addpath /Users/Arne/Documents/MATLAB/eeglab2024.2
end
eeglab
clc
close all