%% Functions to extract power



% specifiy task with 'sternberg' and 'nback', bzw. 'grating' and use if
% statements for indices

% Add IAF and IAF power as well

function extract_power(subjects, path)
    % Add EEGLAB and FieldTrip toolboxes
    addpath('/Users/Arne/Documents/matlabtools/eeglab2024.0');
    eeglab;
    clc;
    close all;

    % Loop over each subject
    for subj = 1:length(subjects)
        datapath = fullfile(path, subjects{subj}, 'eeg');
        cd(datapath)
        close all

        % Load EEG data and headmodel
        load dataEEG_sternberg
        load('/Volumes/methlab/Students/Arne/MA/headmodel/ant128lay.mat');

        % Identify indices of trials for each condition
        ind2 = find(data.trialinfo == 52);
        ind4 = find(data.trialinfo == 54);
        ind6 = find(data.trialinfo == 56);

        % Power analysis for retention interval (1-2 seconds)
        latencyWindow = [1 2];
        
        % Perform the analysis for different configurations
        power_standard = perform_power_analysis(data, latencyWindow, ind2, ind4, ind6, 'no', 'pow');
        power_trials = perform_power_analysis(data, latencyWindow, ind2, ind4, ind6, 'yes', 'pow');
        fooof_power = perform_power_analysis(data, latencyWindow, ind2, ind4, ind6, 'no', 'fooof_peaks');

        % Save power data to the corresponding subject folder
        save_data(datapath, power_standard, power_trials, fooof_power);
    end
end

function power = perform_power_analysis(data, latency, ind2, ind4, ind6, keepTrials, outputType)
    cfg = [];
    cfg.latency = latency; % segment here only for retention interval
    dat = ft_selectdata(cfg, data);
    
    % Frequency analysis configuration
    cfg = [];
    cfg.output = outputType; % 'pow' for standard or 'fooof_peaks' for FOOOF
    cfg.method = 'mtmfft'; % multi taper fft method
    cfg.taper = 'dpss'; % multiple tapers
    cfg.tapsmofrq = 1; % smoothing frequency
    cfg.foilim = [3 30]; % frequencies of interest (foi)
    cfg.keeptrials = keepTrials;
    cfg.pad = 10;
    
    % Analysis for each condition
    cfg.trials = ind2;
    powload2 = ft_freqanalysis(cfg, dat);
    
    cfg.trials = ind4;
    powload4 = ft_freqanalysis(cfg, dat);
    
    cfg.trials = ind6;
    powload6 = ft_freqanalysis(cfg, dat);
    
    power = struct('powload2', powload2, 'powload4', powload4, 'powload6', powload6);
end

function save_data(datapath, power_standard, power_trials, fooof_power)
    cd(datapath);
    
    % Save the standard power data
    save('power_stern.mat', '-struct', 'power_standard');
    
    % Save the trial-based power data
    save('power_stern_trials.mat', '-struct', 'power_trials');
    
    % Save the FOOOF power data
    save('power_stern_fooof.mat', '-struct', 'fooof_power');
end
