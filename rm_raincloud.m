function h = rm_raincloud(data, colours, plot_top_to_bottom, raindrop_size, plot_mean_dots, connecting_lines)
%% Check dimensions of data (should be M x 2 where M is the number of subjects, 2 for low and high contrast)
[n_subjects, n_conditions] = size(data);

% Make sure we have the correct number of colours
assert(all(size(colours) == [n_conditions 3]), 'Number of colors does not match number of conditions');

%% Default arguments
if nargin < 3
    plot_top_to_bottom  = 0;    % Left-to-right plotting by default
end

%% Calculate properties of density plots

% Granularity for density estimation
density_granularity = 200;
n_bins = repmat(density_granularity, n_subjects, n_conditions);

% Calculate kernel densities
for conds = 1:n_conditions
    for subj = 1:n_subjects
        % Compute density using 'ksdensity'
        bandwidth           = [];
        [ks{subj, conds}, x{subj, conds}] = ksdensity(data{subj, conds}, 'NumPoints', n_bins(subj, conds), 'bandwidth', bandwidth);

        % Define the faces to connect each adjacent f(x) and the corresponding points at y = 0.
        q{subj, conds} = (1:n_bins(subj, conds) - 1)';
        faces{subj, conds} = [q{subj, conds}, q{subj, conds} + 1, q{subj, conds} + n_bins(subj, conds) + 1, q{subj, conds} + n_bins(subj, conds)];
    end
end

% Determine spacing between plots
spacing = 2 * mean(mean(cellfun(@max, ks)));
ks_offsets = [0:n_conditions-1] .* spacing;

% Flip so first plot in series is plotted on the top
ks_offsets = fliplr(ks_offsets);

% Calculate patch vertices from kernel density
for conds = 1:n_conditions
    for subj = 1:n_subjects
        if conds == 2 % Mirror the second condition by negating the ks_offsets
            verts{subj, conds} = [x{subj, conds}', -ks{subj, conds}' + ks_offsets(conds); x{subj, conds}', ones(n_bins(subj, conds), 1) * -ks_offsets(conds)];
        else
            verts{subj, conds} = [x{subj, conds}', ks{subj, conds}' + ks_offsets(conds); x{subj, conds}', ones(n_bins(subj, conds), 1) * ks_offsets(conds)];
        end
    end
end

% Jitter for the raindrops
jit_width = spacing / 8;

for conds = 1:n_conditions
    for subj = 1:n_subjects
        jit{subj,conds} = jit_width + rand(1, length(data{subj,conds})) * jit_width;
    end
end

% Means (for mean dots)
cell_means = cellfun(@mean, data);

%% Plot
hold on

% Patches
for conds = 1:n_conditions
    for subj = 1:n_subjects
        h.p{subj, conds} = patch('Faces', faces{subj, conds}, 'Vertices', verts{subj, conds}, 'FaceVertexCData', colours(conds, :), 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 0.5);

        % Modify scatter points to mirror condition 2
        if conds == 2 % Mirror the scatter points of the second condition by negating the y-values
            h.s{subj, conds} = scatter(data{subj, conds}, -jit{subj, conds} + ks_offsets(conds-1)-1, 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.5, 'SizeData', raindrop_size);
        else
            h.s{subj, conds} = scatter(data{subj, conds}, -jit{subj, conds} + ks_offsets(conds), 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.5, 'SizeData', raindrop_size);
        end
    end
end

% Plot grey lines connecting data from condition 1 to condition 2 for each participant
% if connecting_lines == 1
%     for subj = 1:n_subjects
%         % Only draw a line if both conditions have data for this participant
%         if ~isempty(data{subj, 1}) && ~isempty(data{subj, 2})
%             % Get the mean data points for the participant in both conditions
%             x1 = data{1}(subj);
%             x2 = data{2}(subj);
%             y1 = -jit{subj, conds} - ks_offsets(conds);
%             y2 = -jit{subj, conds} + ks_offsets(conds);
% 
%             % Plot a thin grey line with alpha 0.5
%             h.line{subj} = plot([x1, x2], [y1, y2], 'Color', [0.5 0.5 0.5], 'LineWidth', 0.5, 'LineStyle', '-', 'Marker', 'none', 'MarkerEdgeColor', 'none');
%         end
%     end
% end

% Plot mean dots
if plot_mean_dots == 1
    for conds = 1:n_conditions
        for subj = 1:n_subjects
            if conds == 2 % Mirror the mean dots for the second condition by negating the y-values
                h.m(subj, conds) = scatter(cell_means(subj, conds), -ks_offsets, 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 1.5, 'LineWidth', 2);
            else
                h.m(subj, conds) = scatter(cell_means(subj, conds), ks_offsets(conds), 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 1.5, 'LineWidth', 2);
            end
        end
    end
end

%% Clear up axis labels
set(gca, 'YTick', fliplr(ks_offsets));
set(gca, 'YTickLabel', n_subjects:-1:1);

%% Rotate plots if needed
if ~plot_top_to_bottom
    view([90 -90]);
    axis ij
end

end
