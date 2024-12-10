%% Function to update labels
function update_labels(data)
blocks = size(data);
for block = 1:blocks
    if isempty(data{block})
        break;
    else
        try
            for i = 1:blocks
                if ~isempty(data{i}.label)
                    data{block}.label = data{i}.label;
                    break;
                end
            end
        catch
            warning('Error occurred while processing block %d in data structure.', block);
        end
    end
end
end