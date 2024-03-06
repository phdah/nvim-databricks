local utils = require('modules/utils')
local listProfiles = require('modules/profiles').listProfiles
local State = require('modules/states')
local ProfilesStruct = require('modules/profiles').ProfilesStruct
local ClusterWindow = require('modules/window').ClusterWindow
local Window = require('modules/window').Window

local M = {}

---------------------------------
-- Instantiate selection state --
---------------------------------

ClusterSelectionState = State.Selection.new()
RunOutputState = State.RunOutput.new()

-----------------
-- Open window --
-----------------


function M.openClusterWindow(opts)
    -- Dynamically set the height of the window
    opts.winOpts = utils.setWindowSize(opts.winOpts, 0.4, 0.9)

    -- Construct and populate profiles
    local profiles = ProfilesStruct.new()
    profiles:populate(listProfiles(opts.DBConfigFile))
    M.BufferState = State.Buffer.new(profiles)

    -- Construct buffers in BufferState
    M.BufferState.windows = {}
    for _, v in pairs(M.BufferState.profiles) do
        local window = ClusterWindow.new(opts, tostring(v), M.BufferState.profiles)

        table.insert(M.BufferState.windows, window)

    end

    -- Create the initial window
    local win = M.BufferState.windows[1]:createClusterWindow(nil, M.BufferState.windows)
    -- Setup remaining windows
    for i=2, #M.BufferState.windows do
        M.BufferState.windows[i]:createClusterWindow(win, M.BufferState.windows)
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

--[[
Run the current file, given specified cluster
and profile from selection in DBOpen. If no
selection has been made, the DEFAULT profile
is used from your DBConfigFile ('~/.databrickscfg' )
configuration file
]]
function M.runSelection(opts)
    local command = parseCommand(opts)

    -- Dynamically set the height of the window
    opts.winOpts = utils.setWindowSize(opts.winOpts, 0.7, 0.9)

    local window = Window.new(opts, opts.python)
    window:createWindow()
    RunOutputState[opts.python] = window

    vim.fn.termopen(command)

end

--[[
Open the run output, if any exists
]]
function M.runOutputOpen(opts)
    if not RunOutputState[opts.python] then
        print("No run performed yet. Run command :DBRun to run the current file. See :h DBRun")
        return
    end
    RunOutputState[opts.python]:createWindow()
end

-------------
-- Returns --
-------------

return M

