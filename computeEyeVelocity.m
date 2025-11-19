function [velocityTrlAvg, velocityTimeSeries] = computeEyeVelocity(dataET, window_size)
% COMPUTEEYEVELOCITY  Compute smoothed eye velocity and 2D speed from gaze position.
%
% Syntax:
%   [velocityTrlAvg, velocityTimeSeries] = computeEyeVelocity(dataET, window_size)
%
% Input:
%   dataET      - FieldTrip-like eye-tracking struct with fields:
%                   .trial{trl} : [nChan x nSamples], channels 1 (X) and 2 (Y)
%                   .time{trl}  : [1 x nSamples] time stamps (in seconds)
%                   .fsample    : scalar, sampling rate in Hz
%   window_size - length of moving-average window in samples (for smoothing).
%
% Output:
%   velocityTrlAvg     - [nTrials x 3] matrix with trial-wise average velocity
%                        over the interval 0.3–2.0 s:
%                           col 1 = mean |vx|   (horizontal)
%                           col 2 = mean |vy|   (vertical)
%                           col 3 = mean speed  (2D Euclidean)
%
%   velocityTimeSeries - struct with the same format as dataET, but:
%                           trial{trl}(1,:) = smoothed |X-velocity|
%                           trial{trl}(2,:) = smoothed |Y-velocity|
%                           trial{trl}(3,:) = smoothed 2D speed
%                           time{trl}       = time stamps for velocity samples
%
% Notes:
%   - Velocity is computed as the derivative of smoothed position (movmean),
%     then absolute value (or speed) is smoothed again.
%   - Because of diff(), the velocity time series is one sample shorter
%     than the original position time series.
%   - Trial averages are computed only across samples with 0.3 <= t <= 2.0 s.

    % Copy input struct so we keep meta-info (cfg, label, etc.)
    velocityData = dataET;

    sampling_rate = dataET.fsample;
    nTrials       = numel(dataET.trial);

    % Preallocate per-trial averages
    vx_mean    = nan(nTrials, 1);
    vy_mean    = nan(nTrials, 1);
    speed_mean = nan(nTrials, 1);

    % Time window for averaging (in seconds)
    t_min = 0.3;
    t_max = 2.0;

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
        speed = sqrt(vx.^2 + vy.^2);
        speed_smoothed = movmean(speed, window_size);

        % Match time vector to velocity length (one sample shorter than original)
        t = dataET.time{trl};
        nVelSamples = numel(speed_smoothed);  % also matches vx_smoothed, vy_smoothed
        t_vel = t(1:nVelSamples);

        % Allocate new trial matrix with correct number of samples
        velocityData.trial{trl} = zeros(3, nVelSamples);

        % Fill velocity channels
        velocityData.trial{trl}(1,:) = vx_smoothed;
        velocityData.trial{trl}(2,:) = vy_smoothed;
        velocityData.trial{trl}(3,:) = speed_smoothed;

        velocityData.time{trl} = t_vel;

        % -----------------------------------------------------------------
        % Trial-wise averages in the window [0.3, 2.0] seconds
        % -----------------------------------------------------------------
        idx_window = t_vel >= t_min & t_vel <= t_max;

        if any(idx_window)
            vx_mean(trl)    = mean(vx_smoothed(idx_window));
            vy_mean(trl)    = mean(vy_smoothed(idx_window));
            speed_mean(trl) = mean(speed_smoothed(idx_window));
        else
            % If trial is too short or time axis does not cover 0.3–2.0 s,
            % leave as NaN.
            vx_mean(trl)    = NaN;
            vy_mean(trl)    = NaN;
            speed_mean(trl) = NaN;
        end
    end

    % Collect per-trial averages into [nTrials x 3] matrix
    velocityTrlAvg = [vx_mean, vy_mean, speed_mean];

    % Return full trial-wise struct
    velocityTimeSeries = velocityData;
end
