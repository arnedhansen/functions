%% Function to convert MATLAB struct arrays to csv files
function struct_to_csv(path_matlab_struct, name_matlab_struct, path_output_csv)

% Load the data
load(path_matlab_struct);

% Convert the structure to a table
data_table = struct2table(name_matlab_struct);

% Export the table to CSV
writetable(data_table, path_output_csv);
end

