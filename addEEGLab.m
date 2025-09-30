function addEEGLab
if ispc == 1
    addpath('W:\Students\Arne\toolboxes\eeglab2025.1.0')
else
    addpath('/Volumes/g_psyplafor_methlab$/Students/Arne/toolboxes/eeglab2025.1.0')
end
eeglab
clc
close all