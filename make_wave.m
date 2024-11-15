%% Function to create a custom waveform for DSP tutorial
function make_wave(x, y)
    plot(x, y, 'b')
    ylim([-1.1, 1.1])
    ax = gca;
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'on';
    hold on
    yline(0, 'k');
end
