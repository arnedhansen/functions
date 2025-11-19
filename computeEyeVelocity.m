function [velocityTrlAvg, velocityTimeSeries] = computeEyeVelocity(dataET, window_size)
% COMPUTEEYEVELOCITY  Compute smoothed eye velocity from gaze position.
%
% Syntax:
%   [velocityTrlAvg, velocityTimeSeries] = computeEyeVelocity(dataET, window_size)
%
% Input:
%   dataET      - FieldTrip-like eye-tracking struct with fields:
%                   .trial{trl} : [nChan x nSamples], channels 1 (X) and 2 (Y)
%                   .time{trl}  : [1 x nSamples] time stamps
%                   .fsample    : scalar, sampling rate in Hz
%   window_size - length of moving-average window in samples (for smoothing).
%
% Output:
%   velocityTrlAvg     - [3 x nTime] matrix containing trial-averaged
%                        smoothed absolute velocity:
%                           row 1 = horizontal |vx|
%                           row 2 = vertical   |vy|
%                           row 3 = 2D speed   sqrt(vx^2 + vy^2)
%                        Time axis corresponds to velocityTimeSeries.time{1}(1:nTime).
%
%   velocityTimeSeries - struct with the same format as dataET, but:
%                           trial{trl}(1,:) = smoothed |X-velocity|
%                           trial{trl}(2,:) = smoothed |Y-velocity|
%                           trial{trl}(3,:) = smoothed 2D speed
%                           time{trl}       = time stamps for velocity samples
%
% Notes:
%   - Velocity is computed as the derivative of smoothed position (movmean),
%     then the absolute value of velocity (and 2D speed) is smoothed again.
%   - Because of diff(), the velocity time series is one sample shorter
%     than the original position time series.
%   - Input units are preserved (e.g. px → px/s, deg → deg/s).

    % Copy input struct
    velocityData  = dataET;
    sampling_rate = dataET.fsample;
    nTrials       = numel(dataET.trial);

    % Loop over trials and compute velocity for X, Y, and 2D speed
    for trl = 1:nTrials

        % --- Horizontal position (channel 1) ---
        x_pos = dataET.trial{trl}(1,:);

        % Smooth position before differentiation
        x_pos_smoothed = movmean(x_pos, window_size);

        % Differentiate and convert to velocity (per second)
        vx = diff(x_pos_smoothed) * sampling_rate;

        % Smooth absolute horizontal velocity
        vx_smoothed = movmean(abs(vx), window_size);

        % --- Vertical position (channel 2) ---
        y_pos = dataET.trial{trl}(2,:);
        y_pos_smoothed = movmean(y_pos, window_size);
        vy = diff(y_pos_smoothed) * sampling_rate;

        % Smooth absolute vertical velocity
        vy_smoothed = movmean(abs(vy), window_size);

        % --- 2D Euclidean speed (combining horizontal and vertical) ---
        % Compute speed from raw velocity components, then smooth
        speed = sqrt(vx.^2 + vy.^2);
        speed_smoothed = movmean(speed, window_size);

        % Match time vector to velocity (one sample shorter than original)
        t = dataET.time{trl};
        nVelSamples = numel(vx_smoothed);  % also matches vy_smoothed and speed_smoothed
        t_vel = t(1:nVelSamples);

        % Write into output struct
        velocityData.trial{trl}(1,:) = vx_smoothed;
        velocityData.trial{trl}(2,:) = vy_smoothed;
        velocityData.trial{trl}(3,:) = speed_smoothed;

        % If you need to preserve the original 3rd channel (e.g. pupil),
        % you could move it to a 4th row as:
        % if size(dataET.trial{trl}, 1) >= 3
        %     velocityData.trial{trl}(4,:) = dataET.trial{trl}(3,1:nVelSamples);
        % end

        velocityData.time{trl} = t_vel;
    end

    % ---------------------------------------------------------------------
    % Trial-averaged velocity time course (across trials)
    % ---------------------------------------------------------------------

    % Trials can differ in length; for averaging across trials,
    % align to the shortest velocity time series.
    trlLengths = cellfun(@(x) size(x,2), velocityData.trial);
    minLen     = min(trlLengths);

    velX   = zeros(nTrials, minLen);
    velY   = zeros(nTrials, minLen);
    speed2 = zeros(nTrials, minLen);

    for trl = 1:nTrials
        velX(trl,:)   = velocityData.trial{trl}(1,1:minLen);
        velY(trl,:)   = velocityData.trial{trl}(2,1:minLen);
        speed2(trl,:) = velocityData.trial{trl}(3,1:minLen);
    end

    % Mean across trials → [3 x minLen]
    velocityTrlAvg = [
        mean(velX,   1);
        mean(velY,   1);
        mean(speed2, 1)
    ];

    % Return full trial-wise struct
    velocityTimeSeries = velocityData;
end
