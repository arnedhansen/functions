%% Function to exclude epochs with task condition
function EEG = exclude_epochs(EEG, trigger)
% Get the event information
events = EEG.event;

% Identify epochs to keep
epochs_to_keep = true(1, EEG.trials);
for i = 1:length(events)
    if strcmp(events(i).type, trigger)
        epoch_idx = events(i).epoch;
        epochs_to_keep(epoch_idx) = false;
    end
end

% Select the epochs that do not contain the specified trigger
EEG = pop_select(EEG, 'trial', find(epochs_to_keep));
end

%% ALTERNATIVE to exclude epochs
% epochs_to_exclude = find(cellfun(@(x) any(strcmp(x, '17')), {EEG.epoch.eventtype}));
% EEG = pop_select(EEG, 'notrial', epochs_to_exclude);
% pop_eegplot(EEG, 1, 1, 1); % Visualise the remaining epochs