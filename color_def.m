% Script to define colors for plotting

function colors = color_def(projectName)
    if strcmp(projectName, 'AOC')
        colors = [1 0.416 0.553; 0.902 0.855 0.788]; 
    elseif strcmp(projectName, 'GCP')
        colors = [0.902 0.855 0.788; 0.557 0.416 0.553]; % Beige and purple
        % A very light, muted tone that resembles "Linen", "Beige", or "Champagne".
        % A darker, muted purple tone. It could be described as "Dusty Plum", "Taupe Purple", or "Heather".
    end
end

% UZH colors?

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
