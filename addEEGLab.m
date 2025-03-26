function addEEGLab
if ispc == 1
    addpath W:\Students\Arne\toolboxes\eeglab2024.2
else
    addpath /Volumes/methlab/Students/Arne/toolboxes/eeglab2024.2
end
eeglab
clc
close all