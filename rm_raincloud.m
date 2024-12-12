function h = rm_raincloud(data, colours, plot_top_to_bottom, density_type, bandwidth)
% This function will plot separate rainclouds for low contrast and high contrast data
% without overlapping, and each condition will be placed on different points on the X-axis.

%% Check dimensions of data
[n_subjects, n_conditions] = size(data); % n_conditions should be 2 (low and high contrast)

% Make sure we have the correct number of colours (one per condition)
assert(all(size(colours) == [n_conditions 3]), 'Number of colours does not match number of conditions');

%% Default arguments
if nargin < 3
    plot_top_to_bottom = 0;    % Left-to-right plotting by default
end

if nargin < 4
    density_type = 'ks'; % Use 'ksdensity' to create cloud shapes
end

if nargin < 5
    bandwidth = [];   % Let the function specify the bandwidth
end

%% Calculate properties of density plots
density_granularity = 200;
n_bins = repmat(density_granularity, n_subjects, n_conditions);

% Calculate kernel densities
for i = 1:n_subjects
    for j = 1:n_conditions
        switch density_type
            case 'ks'
                % Compute density using 'ksdensity'
                [ks{i, j}, x{i, j}] = ksdensity(data{i, j}, 'NumPoints', n_bins(i, j), 'bandwidth', bandwidth);
            case 'rash'
                % Check for rst_RASH function (from Robust stats toolbox) in path, fail if not found
                assert(exist('rst_RASH', 'file') == 2, 'Could not compute density using RASH method. Do you have the Robust Stats toolbox on your path?');
                % Compute density using RASH
                [x{i, j}, ks{i, j}] = rst_RASH(data{i, j});
                % Override default 'n_bins' as rst_RASH determines number of bins
                n_bins(i, j) = size(ks{i, j}, 2);
        end

        % Define the faces to connect each adjacent f(x) and the corresponding points at y = 0.
        q{i, j} = (1:n_bins(i, j) - 1)';
        faces{i, j} = [q{i, j}, q{i, j} + 1, q{i, j} + n_bins(i, j) + 1, q{i, j} + n_bins(i, j)];
    end
end

% Determine spacing between plots (add space between conditions)
spacing = 2 * mean(mean(cellfun(@max, ks)));
ks_offsets = [0:n_subjects-1] * spacing;

% Adjust x-axis offsets for separate conditions (to avoid overlap)
x_offsets = [1, 3]; % Low contrast at position 1, high contrast at position 3

% Calculate patch vertices from kernel density
for i = 1:n_subjects
    for j = 1:n_conditions
        verts{i, j} = [x{i, j}', ks{i, j}' + ks_offsets(i); x{i, j}', ones(n_bins(i, j), 1) * ks_offsets(i)];
    end
end

% Jitter for the raindrops
jit_width = spacing / 8;
raindrop_size = 100;
for i = 1:n_subjects
    for j = 1:n_conditions
        jit{i, j} = jit_width + rand(1, length(data{i, j})) * jit_width;
    end
end

% Means (for mean dots)
cell_means = cellfun(@mean, data);

%% Plot
hold on

% Patches (for rainclouds)
for i = 1:n_subjects
    for j = 1:n_conditions
        h.p{i, j} = patch('Faces', faces{i, j}, 'Vertices', verts{i, j}, 'FaceVertexCData', colours(j, :), ...
            'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', 0.5);
        h.s{i, j} = scatter(data{i, j}, -jit{i, j} + ks_offsets(i), 'MarkerFaceColor', colours(j, :), ...
            'MarkerEdgeColor', 'none', 'MarkerFaceAlpha', 0.5, 'SizeData', raindrop_size);
    end
end

% Plot mean lines (connecting conditions within each subject)
for i = 1:n_subjects - 1 % We have n_subjects-1 lines because lines connect pairs of points
    for j = 1:n_conditions
        h.l(i, j) = line(cell_means([i i+1], j), ks_offsets([i i+1]), 'LineWidth', 4, 'Color', colours(j, :));
    end
end

% Plot mean dots (large dot representing mean of each condition)
for i = 1:n_subjects
    for j = 1:n_conditions
        h.m(i, j) = scatter(cell_means(i, j), ks_offsets(i) + x_offsets(j), 'MarkerFaceColor', colours(j, :), ...
            'MarkerEdgeColor', [0 0 0], 'MarkerFaceAlpha', 1, 'SizeData', raindrop_size * 2, 'LineWidth', 2);
    end
end

% Clear up axis labels
set(gca, 'YTick', fliplr(ks_offsets));
set(gca, 'YTickLabel', n_subjects:-1:1);

%% Determine plot rotation (optional, as per your previous request)
if ~plot_top_to_bottom
    view([90 -90]);
    axis ij
end

end
