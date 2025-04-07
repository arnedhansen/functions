function [trialsToKeep, excludedTrialIdx] = fixCheck(dataET, window, fixThresh, distOK)
% fixCheck checks if participants were fixating the centre during pre-stimulus period
%
% Inputs:
%   - dataET: FieldTrip data structure with eye-tracking channels
%   - window: [start, end] in seconds (e.g., [-0.5 0])
%   - fixThresh: proportion of samples that must fall within allowed distance
%   - distOK: maximum Euclidean distance from centre (in pixels, same unit as gaze)
%
% Outputs:
%   - trialsToKeep: logical index vector for good trials
%   - excludedTrialIdx: indices of trials excluded

    screenCentreX = 400;  % half of screen width (800)
    screenCentreY = 300;  % half of screen height (600)

    nTrials = numel(dataET.trial);
    trialsToKeep = true(nTrials, 1);  % Initialise all to true

    for t = 1:nTrials
        timeVec = dataET.time{t};
        idx = find(timeVec >= window(1) & timeVec <= window(2));

        if isempty(idx)
            trialsToKeep(t) = false;
            continue;
        end

        % Gaze positions
        xL = dataET.trial{t}(strcmp(dataET.label, 'L-GAZE-X'), idx);
        yL = dataET.trial{t}(strcmp(dataET.label, 'L-GAZE-Y'), idx);

        % Compute Euclidean distances from screen centre (400, 300)
        distL = sqrt((xL - screenCentreX).^2 + (yL - screenCentreY).^2);

        % Check how many samples fall within allowed distance
        okSamples = (distL <= distOK);

        % Mark trial as invalid if not enough samples within threshold
        if mean(okSamples) < fixThresh
            trialsToKeep(t) = false;
        end
    end

    excludedTrialIdx = find(~trialsToKeep);
end
