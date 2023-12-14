local M = {}

M.setCluster = function(clusterInfo, configFile)
    local clusterId = clusterInfo[1]
    local clusterName = clusterInfo[2]

    local command = 'sed -i \'\' \'/^\\[DEFAULT\\]/, /^\\[/{s/^cluster_id = .*/cluster_id = ' .. clusterId .. '/;}\' ' .. configFile

    os.execute(command)
    if vim.v.shell_error ~= 0 then
        print('Error executing command: ' .. command)
    else
        print('Changed Spark cluster to: ' .. clusterName)
    end

end

return M
