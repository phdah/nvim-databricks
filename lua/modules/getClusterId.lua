local M = {}

M.getClusterName = function(win, buf)
    -- Get the current line number
    local lineNum = vim.api.nvim_win_get_cursor(win)[1]
    -- Get the line's content
    local lineContent = vim.api.nvim_buf_get_lines(buf, lineNum - 1, lineNum, false)[1]

    -- Split the lineContent on space and get the cluster name
    -- The status is the forst word, so we skip that
    local wordIteration = 0
    local clusterName = ''
    for word in lineContent:gmatch("%S+") do
        if wordIteration == 1 then
            clusterName = word
        elseif wordIteration > 1 then
            clusterName = clusterName .. ' ' .. word
        end
        wordIteration = wordIteration + 1
    end
    return clusterName
end


M.getClusterId = function(clusterName)
    -- Fetch the cluster id, for the given name
    -- Note, don't take names with " or '
    local command = "databricks clusters list --output JSON | jq '.clusters[] | select(.cluster_name == \"" .. clusterName .. "\") | .cluster_id'"

    local clusterId = vim.fn.system(command)
    if vim.v.shell_error ~= 0 then
        print("Error executing command: " .. command)
    end
    -- Strip away newline
    clusterId = clusterId:gsub('"', "")
    clusterId = clusterId:gsub("\n", "")
    return {clusterId, clusterName}

end

return M
