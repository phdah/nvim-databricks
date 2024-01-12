local utils = require('modules/utils')
local listProfiles = require('modules/profiles').listProfiles
local State = require('modules/states')
local ProfilesStruct = require('modules/profiles').ProfilesStruct
local Window = require('modules/window').Window

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

    -- utils.printTable(M.BufferState)

end

-------------------
-- Run selection --
-------------------

function M.runSelection()
    print("Running")
end

-------------
-- Returns --
-------------

return M

