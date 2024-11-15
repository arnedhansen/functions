%% Function to select data in FieldTrip structures
function selected_data = select_data(cfg_latency, cfg_frequency, data)
    cfg = [];
    cfg.latency = cfg_latency;
    cfg.frequency = cfg_frequency;
    cfg.avgovertime = 'yes';
    selected_data = ft_selectdata(cfg, data);
end
