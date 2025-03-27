% Script to define colors for plotting depending on project name

function colors = color_def(projectName)
if strcmp(projectName, 'AOC')
    % "Normal" AOC pastel colors
    colors = [0.68, 0.85, 0.90;  % Pastel blue
        0.60, 0.80, 0.60;  % Pastel green
        1.00, 0.70, 0.75]; % Pastel red
    % DataViz pastel colors
    % colors = [1.000, 0.549, 0.000;  % Pastel orange
    %           0.627, 0.204, 0.941;  % Pastel magenta
    %           0.082, 0.565, 0.565]; % Pastel green
elseif strcmp(projectName, 'GCP')
    colors = [
        0.937, 0.804, 0.867; % Pale rose
        0.902 0.855 0.788; % Beige
        0.957 0.714 0.514; % Pastel peach
        0.557 0.416 0.553; % Purple
        ];
end
end

% %% UZH colors?
%
%
% %% Pastel colors
% colors = [
%     0.902 0.855 0.788; % Beige
%     0.557 0.416 0.553; % Purple
%     0.957 0.714 0.514; % Pastel peach
%     0.678, 0.847, 0.902; % Soft blue
%     0.667, 0.882, 0.722; % Mint green
%     0.996, 0.890, 0.561; % Pastel yellow
%     0.941, 0.678, 0.678; % Light coral
%     0.753, 0.706, 0.878; % Lavender
%     0.988, 0.733, 0.831; % Blush pink
%     0.992, 0.859, 0.780; % Light apricot
%     0.816, 0.867, 0.710; % Pastel sage
%     0.749, 0.827, 0.933; % Baby blue
%     0.937, 0.804, 0.867; % Pale rose
% ];
%
%% Visualization
% rgbMatrix = colors;
%
% % Create a figure to display colours
% figure;
%
% % Loop through each row in the RGB matrix
% for i = 1:size(rgbMatrix, 1)
%     % Plot each colour as a rectangle
%     rectangle('Position', [i-1, 0, 1, 1], 'FaceColor', rgbMatrix(i, :), 'EdgeColor', 'none');
%     hold on;
% end
%
% % Adjust axis to fit all rectangles
% axis equal;
% axis off;
% xlim([0 size(rgbMatrix, 1)]);
% ylim([0 1]);
