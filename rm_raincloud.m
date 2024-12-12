function h = rm_raincloud(data, colours, add_boxplot, plot_top_to_bottom, raindrop_size, plot_mean_dots, connecting_lines)
%% Check dimensions of data (should be M x 2 where M is the number of groupects, 2 for low and high contrast)
[n_groups, n_conditions] = size(data);
n_subjects = max(size(data{1}));

% Make sure we have the correct number of colours
assert(all(size(colours) == [n_conditions 3]), 'Number of colors does not match number of conditions');

%% Default arguments
if nargin < 3
    plot_top_to_bottom  = 0;    % Left-to-right plotting by default
end

%% Calculate properties of density plots

% Granularity for density estimation
density_granularity = 200;
n_bins = repmat(density_granularity, n_groups, n_conditions);

% Calculate kernel densities
for conds = 1:n_conditions
    for group = 1:n_groups
        % Compute density using 'ksdensity'
        bandwidth           = [];
        [ks{group, conds}, x{group, conds}] = ksdensity(data{group, conds}, 'NumPoints', n_bins(group, conds), 'bandwidth', bandwidth);

        % Define the faces to connect each adjacent f(x) and the corresponding points at y = 0.
        q{group, conds} = (1:n_bins(group, conds) - 1)';
        faces{group, conds} = [q{group, conds}, q{group, conds} + 1, q{group, conds} + n_bins(group, conds) + 1, q{group, conds} + n_bins(group, conds)];
    end
end

% Determine spacing between plots
spacing = 2 * mean(mean(cellfun(@max, ks)));
ks_offsets = [0:n_conditions-1] .* spacing;

% Flip so first plot in series is plotted on the top
ks_offsets = fliplr(ks_offsets);

% Calculate patch vertices from kernel density
for conds = 1:n_conditions
    for group = 1:n_groups
        if conds == 2 % Mirror the second condition by negating the ks_offsets
            verts{group, conds} = [x{group, conds}', -ks{group, conds}' + ks_offsets(conds); x{group, conds}', ones(n_bins(group, conds), 1) * -ks_offsets(conds)];
        else
            verts{group, conds} = [x{group, conds}', ks{group, conds}' + ks_offsets(conds); x{group, conds}', ones(n_bins(group, conds), 1) * ks_offsets(conds)];
        end
    end
end

% Jitter for the raindrops
jit_width = spacing / 8;

for conds = 1:n_conditions
    for group = 1:n_groups
        jit{group,conds} = jit_width + rand(1, length(data{group,conds})) * jit_width;
    end
end

% Means (for mean dots)
cell_means = cellfun(@mean, data);

%% Plot
hold on

% Preallocate for jittered y-positions
jit_y = cell(n_groups, n_conditions);

for conds = 1:n_conditions
    for group = 1:n_groups
        % Calculate jittered y-positions with offsets
        if conds == 2
            jit_y{group, conds} = -jit{group, conds} + ks_offsets(conds) + spacing*0.375;
        else
            jit_y{group, conds} = -jit{group, conds} + ks_offsets(conds);
        end

        % Create the patch objects
        h.p{group, conds} = patch('Faces', faces{group, conds}, 'Vertices', verts{group, conds}, ...
            'FaceVertexCData', colours(conds, :), 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 0.5);

        % Create scatter plot using pre-calculated jittered y-positions
        h.s{group, conds} = scatter(data{group, conds}, jit_y{group, conds}, ...
            'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', 0.5, 'SizeData', raindrop_size);
    end
end

% Plot grey lines connecting data from condition 1 to condition 2 for each participant
if connecting_lines == 1
    for group = 1:n_groups
        for subj = 1:n_subjects
            % Only draw a line if both conditions have data for this participant
            if ~isempty(data{group, 1}) && ~isempty(data{group, 2})
                % Get the data points for the participant in both conditions
                x1 = data{group, 1}(subj);
                x2 = data{group, 2}(subj);

                % Get the corresponding pre-calculated y positions
                y1 = jit_y{group, 1}(subj);
                y2 = jit_y{group, 2}(subj);

                % Plot a thin grey line with alpha 0.5
                plot([x1, x2], [y1, y2], 'Color', [0.5 0.5 0.5], ...
                    'LineWidth', 0.5, 'LineStyle', '-', 'Marker', 'none');
            end
        end
    end
end

% Plot mean dots
if plot_mean_dots == 1
    for conds = 1:n_conditions
        for group = 1:n_groups
            if conds == 2 % Mirror the mean dots for the second condition by negating the y-values
                h.m(group, conds) = scatter(cell_means(group, conds), -ks_offsets, 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 1.5, 'LineWidth', 2);
            else
                h.m(group, conds) = scatter(cell_means(group, conds), ks_offsets(conds), 'MarkerFaceColor', colours(conds, :), 'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 1.5, 'LineWidth', 2);
            end
        end
    end
end

%% Clear up axis labels
set(gca, 'YTick', fliplr(ks_offsets));
set(gca, 'YTickLabel', n_groups:-1:1);
set(gca, 'YTick', [0, ks_offsets(1)], 'YTickLabel', {'High Contrast', 'Low Contrast'}, 'FontSize', 20);

%% Rotate plots if needed
if ~plot_top_to_bottom
    view([90 -90]);
    axis ij
end

end
