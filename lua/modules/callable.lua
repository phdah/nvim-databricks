local utils = require('modules/utils')
local listProfiles = require('modules/profiles').listProfiles
local State = require('modules/states')
local ProfilesStruct = require('modules/profiles').ProfilesStruct
local Window = require('modules/window').Window
local async = require('modules/databricks_async')

local M = {}

---------------------------------
-- Instantiate selection state --
---------------------------------

ClusterSelectionState = State.Selection.new()

-----------------
-- Open window --
-----------------


function M.openWindow(opts)
    -- Construct and populate profiles
    local profiles = ProfilesStruct.new()
    profiles:populate(listProfiles(opts.DBConfigFile))
    M.BufferState = State.Buffer.new(profiles)

    -- Construct buffers in BufferState
    M.BufferState.windows = {}
    for _, v in pairs(M.BufferState.profiles) do
        local window = Window.new(opts, tostring(v), M.BufferState.profiles)

        table.insert(M.BufferState.windows, window)

    end

    -- Create the initial window
    local win = M.BufferState.windows[1]:createWindow(nil, M.BufferState.windows)
    -- Setup remaining windows
    for i=2, #M.BufferState.windows do
        M.BufferState.windows[i]:createWindow(win, M.BufferState.windows)
    end

end

-------------------
-- Run selection --
-------------------

local function parseCommand(opts)
    local currentFile = vim.api.nvim_buf_get_name(0)
    local echoCommand = [[echo "==================================" && echo "Running file: ]] .. currentFile:match('.*/(%S*)') .. [[" && echo "Profile: $DATABRICKS_CONFIG_PROFILE" && echo "ClusterID: $DATABRICKS_CLUSTER_ID" && echo "==================================" && ]]
    local command = echoCommand .. opts.python .. " " .. currentFile
    if ClusterSelectionState.profile and ClusterSelectionState.clusterId then
        command = "export DATABRICKS_CONFIG_PROFILE="
        .. ClusterSelectionState.profile
        .. " && export DATABRICKS_CLUSTER_ID="
        .. ClusterSelectionState.clusterId
        .. " && " .. echoCommand .. opts.python .. " " .. currentFile
    else
        print("No cluster selected, using DEFAULT config from " .. opts.DBConfigFile)
    end
    return command
end

function M.runSelection(opts)
    local command = parseCommand(opts)

    vim.cmd('split | terminal ' .. command)
end

-------------
-- Returns --
-------------

return M

