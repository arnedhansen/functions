%% git commit random text change to .txt document

%% Step 1: Create or overwrite a .txt document
% Specify the file path
filePath = '/Users/Arne/Documents/GitHub/gitcommit/date.txt';

% Content to write into the file
content = datestr(now);

% Open file for writing (overwrite mode)
fileID = fopen(filePath, 'w');
if fileID == -1
    error('Failed to create or overwrite the file.');
end

% Write content and close the file
fprintf(fileID, '%s\n', content);
fclose(fileID);

disp(['File created/updated at: ', filePath]);

%% Step 2: Automate Git operations
% Change directory to the Git repository
repoPath = '/Users/Arne/Documents/GitHub/gitcommit';
cd(repoPath);

% Git add
[status, cmdout] = system('git add .');
if status ~= 0
    error(['Git add failed: ', cmdout]);
end
disp('Git add successful.');

% Git commit
commitMessage = '"Auto-commit"';
[status, cmdout] = system(['git commit -m ', commitMessage]);
if status ~= 0
    error(['Git commit failed: ', cmdout]);
end
disp('Git commit successful.');

% Git push
[status, cmdout] = system('git push https://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@github.com/arnedhansen/gitcommit.git main');
if status ~= 0
    error(['Git push failed: ', cmdout]);
end
disp('Git push successful.');
