function h = rm_raincloud(data, colours, plot_top_to_bottom, raindrop_size)
%% check dimensions of data

% Check dimensions of data (should be M x 2 where M is the number of subjects, 2 for low and high contrast)
[n_subjects, n_conditions] = size(data);

% Make sure we have the correct number of colours
assert(all(size(colours) == [n_conditions 3]), 'Number of colors does not match number of conditions');

%% default arguments
if nargin < 3
    plot_top_to_bottom  = 0;    % Left-to-right plotting by default
end

%% Calculate properties of density plots

% Granularity for density estimation
density_granularity = 200;
n_bins = repmat(density_granularity, n_subjects, n_conditions);

% Calculate kernel densities
for j = 1:n_conditions
    for i = 1:n_subjects
        % Compute density using 'ksdensity'
        bandwidth           = [];
        [ks{i, j}, x{i, j}] = ksdensity(data{i, j}, 'NumPoints', n_bins(i, j), 'bandwidth', bandwidth);

        % Define the faces to connect each adjacent f(x) and the corresponding points at y = 0.
        q{i, j} = (1:n_bins(i, j) - 1)';
        faces{i, j} = [q{i, j}, q{i, j} + 1, q{i, j} + n_bins(i, j) + 1, q{i, j} + n_bins(i, j)];
    end
end

% Determine spacing between plots
spacing = 2 * mean(mean(cellfun(@max, ks)));
ks_offsets = [0:n_conditions-1] .* spacing;

% Flip so first plot in series is plotted on the top
ks_offsets = fliplr(ks_offsets);

% Calculate patch vertices from kernel density
for j = 1:n_conditions
    for i = 1:n_subjects
        verts{i, j} = [x{i, j}', ks{i, j}' + ks_offsets(j); x{i, j}', ones(n_bins(i, j), 1) * ks_offsets(j)];
    end
end

% Jitter for the raindrops
jit_width = spacing / 8;

for j = 1:n_conditions
    for i = 1:n_subjects
        jit{i,j} = jit_width + rand(1, length(data{i,j})) * jit_width;
    end
end

% Means (for mean dots)
cell_means = cellfun(@mean, data);

%% Plot
hold on

% Patches
for j = 1:n_conditions
    for i = 1:n_subjects
        h.p{i, j} = patch('Faces', faces{i, j}, 'Vertices', verts{i, j}, 'FaceVertexCData', colours(j, :), 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        h.s{i, j} = scatter(data{i, j}, -jit{i, j} + ks_offsets(j), 'MarkerFaceColor', colours(j, :), 'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.5, 'SizeData', raindrop_size);
    end
end

% Plot mean lines
for j = 1:n_conditions
    for i = 1:n_subjects - 1
        h.l(i, j) = line(cell_means([i, i+1], j), ks_offsets([i, i+1]), 'LineWidth', 4, 'Color', colours(j, :));
    end
end

% Plot mean dots
% for j = 1:n_conditions
%     for i = 1:n_subjects
%         h.m(i, j) = scatter(cell_means(i, j), ks_offsets(j), 'MarkerFaceColor', colours(j, :), 'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 2, 'LineWidth', 2);
%     end
% end

%% Clear up axis labels
set(gca, 'YTick', fliplr(ks_offsets));
set(gca, 'YTickLabel', n_subjects:-1:1);

%% Rotate plots if needed
if ~plot_top_to_bottom
    view([90 -90]);
    axis ij
end
end
