% Script to define colors for plotting

function colors = color_def(projectName)
    if strcmp(projectName, 'AOC')
        colors = [1 0.416 0.553; 0.902 0.855 0.788] % Beige and purple
    elseif strcmp(projectName, 'GCP')
        colors = [0.557 0.416 0.553; 0.902 0.855 0.788] % Beige and purple
    end
end
