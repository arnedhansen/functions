function [trialsToKeep, excludedTrialIdx] = fixCheck(dataET, window, fixThresh, distOK)
% fixCheck checks if participants were fixating the centre during pre-stimulus period
%
% Inputs:
%   - dataET: FieldTrip data structure with eye-tracking channels
%   - window: [start, end] in seconds (e.g., [-0.5 0])
%   - fixThresh: proportion of samples that must fall within allowed distance
%   - distOK: maximum Euclidean distance from centre (in visual degrees or appropriate units)
%
% Outputs:
%   - trialsToKeep: logical index vector for good trials
%   - excludedTrialIdx: indices of trials excluded

    nTrials = numel(dataET.trial);
    trialsToKeep = true(nTrials, 1);  % Initialise all to true

    for t = 1:nTrials
        timeVec = dataET.time{t};
        trialStart = window(1);
        trialEnd = window(2);
        idx = find(timeVec >= trialStart & timeVec <= trialEnd);

        if isempty(idx)
            trialsToKeep(t) = false;
            continue;
        end

        % Gaze positions
        xL = dataET.trial{t}(strcmp(dataET.label, 'L-GAZE-X'), idx);
        yL = dataET.trial{t}(strcmp(dataET.label, 'L-GAZE-Y'), idx);
        xR = dataET.trial{t}(strcmp(dataET.label, 'R-GAZE-X'), idx);
        yR = dataET.trial{t}(strcmp(dataET.label, 'R-GAZE-Y'), idx);

        % Compute Euclidean distances from centre (0,0)
        distL = sqrt(xL.^2 + yL.^2);
        distR = sqrt(xR.^2 + yR.^2);

        % Check how many samples fall within distance
        okSamples = (distL <= distOK) & (distR <= distOK);

        % Pass if enough samples are OK
        if mean(okSamples) < fixThresh
            trialsToKeep(t) = false;
        end
    end

    excludedTrialIdx = find(~trialsToKeep);
end
