%% Function to interpolate power spectrum over frequencies
function smoothed_data = smooth_tfr(data, orig_freq, new_freq)
% Get dimensions
[n_channels, n_freqs, n_time] = size(data.powspctrm); % [125 × 19 × XX]

% Preallocate the new power spectrum array
powspctrm_interp = nan(n_channels, length(new_freq), n_time);

% Loop over channels and time points to interpolate each frequency spectrum
for ch = 1:n_channels
    for t = 1:n_time
        % Interpolate across the frequency dimension
        powspctrm_interp(ch, :, t) = interp1(orig_freq, squeeze(data.powspctrm(ch, :, t)), new_freq, 'spline');
    end
end

% Update the data structure
smoothed_data = data;
smoothed_data.freq = new_freq;
smoothed_data.powspctrm = powspctrm_interp;
end