%% Function to update labels
function data = update_labels(data)
if ~iscell(data) || isempty(data)
    return
end

blocks = numel(data);
template_label = [];

for i = 1:blocks
    if ~isempty(data{i}) && isfield(data{i}, 'label') && ~isempty(data{i}.label)
        template_label = data{i}.label;
        break
    end
end

if isempty(template_label)
    return
end

for block = 1:blocks
    if isempty(data{block})
        continue
    end
    try
        data{block}.label = template_label;
    catch
        warning('Error occurred while processing block %d in data structure.', block);
    end
end
end