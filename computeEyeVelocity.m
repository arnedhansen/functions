function [velocityTrlAvg, velocityTimeSeries] = computeEyeVelocity(dataET, window_size)
    dataET_smoothed = dataET;
    dataET_smoothed = rmfield(dataET_smoothed,'trial');
    dataET_smoothed = rmfield(dataET_smoothed,'time');
    sampling_rate = dataET.fsample;
    for trl = 1:length(dataET_smoothed.trial)
        
        % Compute the moving average
        smoothed_data = movmean(dataET.trial{trl}(1,:), window_size);
        velocity = diff(smoothed_data) * sampling_rate;
        smoothed_velocity = movmean(abs(velocity), window_size);
        
        dataET_smoothed.trial{trl}(1,:) = abs(velocity);
        dataET_smoothed.time{trl}=dataET.time{trl}(1:end-1);

        smoothed_data = movmean(dataET.trial{trl}(2,:), window_size);
        velocity = diff(smoothed_data) * sampling_rate;
        smoothed_velocity = movmean(abs(velocity), window_size);
        
        dataET_smoothed.trial{trl}(2,:) = abs(velocity);
        dataET_smoothed.trial{trl}(3,:)=dataET.trial{trl}(3,1:end-1);
    end
    velocityTrlAvg = ??
    velocityTimeSeries = ??