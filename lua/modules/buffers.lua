local utils = require('modules/utils')

------------
-- Buffer --
------------

local Buffer = {}
Buffer.__index = Buffer

function Buffer.new(name)
    local self = setmetatable({}, Buffer)
    self.name = name
    return self
end

function Buffer:createBuffer()
    self.buf = vim.api.nvim_create_buf(false, true)
end

function Buffer:getClusters()
    --[[
        The command fetches clusters for the specified profile in the config file.
        Then it JSON parses the output to filter for cluster names not starting
        with "job-". Then it returns all existing clusters like:
        STATE CLUSTER-NAME
    ]]
    local command = "databricks --profile " .. self.name .. " clusters list --output JSON | jq -r '.clusters[] | select(.cluster_name | startswith(\"job-\") | not) | \"\" + .state + \" \" + .cluster_name'"
    -- Execute the shell command and get the clusterList
    self.clusters = utils.callAndPaseCommand(command)
    self.clusterLenght = #self.clusters

end

function Buffer:getName()
    print("Name is: " .. self.name)
end

---------
-- Tab --
---------

local Tab = {
    boarder = "---------------------------",
    header = "[q] quit, [enter] select cluster, [h] left, [l] right",
    columns = "Status    Cluster Name",
    headerLength = 3 + 1 -- Clusters start on +1 line
}
Tab.__index = Tab
setmetatable(Tab, Buffer)

function Tab.new()
    local self = setmetatable({}, Tab)
    return self
end

function Tab:createTabs(profiles)
    local markedProfiles = {}

    for i, profile in ipairs(profiles) do
        local markedList = {}
        for j, p in ipairs(profiles) do
            if i == j then
                table.insert(markedList, "[" .. tostring(p) .. "]")
            else
                table.insert(markedList, tostring(p))
            end
        end
        markedProfiles[tostring(profile)] = table.concat(markedList, "    ")
    end

    self.tabs = markedProfiles
end

-------------
-- Returns --
-------------

local M = {}

M.Tab = Tab

return M
