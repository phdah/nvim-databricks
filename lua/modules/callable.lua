local utils = require('modules/utils')
local listProfiles = require('modules/profiles').listProfiles
local State = require('modules/states')
local ProfilesStruct = require('modules/profiles').ProfilesStruct
local Window = require('modules/window').Window

local M = {}

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

    for i, window in pairs(M.BufferState.windows) do
        print(i)
        print(window.buf)
        utils.printTable(window, window.name .. " ")
    end

    -- utils.printTable(M.BufferState, "BufferState: ")
    -- Create the initial window
    -- M.BufferState.windows[1]:createWindow()

end

-------------
-- Returns --
-------------

return M

