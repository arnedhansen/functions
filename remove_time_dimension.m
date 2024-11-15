%% Function to remove time dimension in FieldTrip data structure
function data_no_time = remove_time_dimension(data)
    data_no_time = rmfield(data, 'time');
    data_no_time.dimord = 'chan_freq';
end