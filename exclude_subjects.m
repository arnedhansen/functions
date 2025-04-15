% Function to exclude subjects from rtf file
function filteredSubjects = exclude_subjects(subjects, project)
if strcmp(project, 'AOC')
    % Open and read the RTF file
    if ispc == 1
        fileID = fopen('W:\Students\Arne\AOC\data\controls\AOC_exclusion_participants.rtf', 'r');
    else
        fileID = fopen('/Volumes/methlab/Students/Arne/AOC/data/controls/AOC_exclusion_participants.rtf', 'r');
    end

    % Read the content as a raw string
    rawText = fread(fileID, '*char')';

    % Close the file
    fclose(fileID);

    % Extract numbers from the text (assuming numbers are separated by spaces or new lines)
    exclusionSubjects = regexp(rawText, '\d+', 'match'); % Extracts numeric strings
    exclusionSubjects = str2double(exclusionSubjects); % Convert to numeric array
    subjectsNumeric = str2double(subjects); % Convert cell array to numeric

    % Exclude subjects
    filteredSubjectsList = setdiff(subjectsNumeric, exclusionSubjects);

    % Convert back to cell array of strings
    filteredSubjects = cellstr(string(filteredSubjectsList));

    % Display the updated subjects list
    disp('Filtered Subjects:');
    disp(filteredSubjectsList');
end
