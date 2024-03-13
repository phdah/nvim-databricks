local Tab = require('modules/buffers').Tab

------------
-- Window --
------------

local Window = {}
Window.__index = Window
setmetatable(Window, Tab)

function Window.new(opts, name)
    local self = setmetatable({}, Window)
    self.name = name
    self.winOpts = opts.winOpts

    -- Run helper functions
    self:createBuffer()
    self:runKeymaps()

    return self
end

-- Create and open a window with instance options
function Window:createWindow()
    -- Open window
    self.win = vim.api.nvim_open_win(self.buf, true, self.winOpts)
end

-- Close opened window
function Window:closeBuffer()
    if vim.api.nvim_buf_is_valid(self.buf) then
        vim.api.nvim_win_close(self.win, false)
    end
end

function Window:keymaps()
    -- Key mapping to close the buffer
    self.keymaps = "[q] quit"
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:closeBuffer()
        end,
    })
end

--[[
Setup keymaps specifically for cluster window
]]
function Window:runKeymaps()
    -- Load default keymaps
    self:keymaps()

    -- Key mapping to rerun the the file
    self.keymaps = self.keymaps .. ", [r] rerun"
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'r', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:closeBuffer()
            vim.cmd("DBRun")
        end,
    })

    -- Finish the keymaps with empty line
    self.keymaps = self.keymaps .. "\n"
end

--------------------
-- CLuster Window --
--------------------

local ClusterWindow = {}
ClusterWindow.__index = ClusterWindow
setmetatable(ClusterWindow, Window)

function ClusterWindow.new(opts, name, profiles)
    local self = setmetatable({}, ClusterWindow)
    self.name = name
    self.states = opts.states
    self.winOpts = opts.winOpts

    -- Run helper functions
    self:createTabs(profiles)
    self:createBuffer()
    self:getClusters(false)
    self.windowLenght = self.headerLength + self.clusterLenght

    -- Setup window
    self:populate()
    self:movementRestriction()

    return self
end

function ClusterWindow:populate()
    -- TODO: check if the lines can all go in one table
    -- Set header
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {self.header, ""})
    -- Set lines in the buffer
    vim.api.nvim_buf_set_lines(self.buf, 2, -1, false, {self.columns, self.boarder})
    vim.api.nvim_buf_set_lines(self.buf, self.headerLength, -1, false, self.clusters)
    -- Static tabs line
    vim.api.nvim_buf_set_lines(self.buf, self.windowLenght, self.windowLenght, false, {self.boarder, self.tabs[self.name]})
end

function ClusterWindow:movementRestriction()
    -- Don't clear to append to augroup
    self.augroup = vim.api.nvim_create_augroup('LimitCursorMovement', { clear = false })
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = self.augroup,
        buffer = self.buf,
        callback = function()
            local cursor = vim.api.nvim_win_get_cursor(0)
            if cursor[1] < (self.headerLength+1) or cursor[1] > (self.windowLenght-1) then
                vim.api.nvim_win_set_cursor(0, {math.min(math.max(self.headerLength+1, cursor[1]), self.windowLenght), cursor[2]})
            end
        end
    })
end

function ClusterWindow:setParentAndChildProfile(bufferState)
    local index = nil
    local bufferStateLength = #bufferState

    for i, profile in ipairs(bufferState) do
        if profile.name == self.name then
            index = i
            break
        end
    end

    self.parent = bufferState[index == 1 and bufferStateLength or (index-1)].buf
    self.child = bufferState[index % bufferStateLength + 1].buf
end

function ClusterWindow:closeListOfBuffers()
    for _, buf in ipairs({self.buf, self.parent, self.child}) do
        -- Close each buffer if it's valid
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

function ClusterWindow:getClusterName()
    -- Get the current line number
    local lineNum = vim.api.nvim_win_get_cursor(self.win)[1]
    -- Get the line's content
    local lineContent = vim.api.nvim_buf_get_lines(self.buf, lineNum - 1, lineNum, false)[1]

    -- Split the lineContent on space and get the cluster name
    -- The status is the forst word, so we skip that
    return lineContent:match('%s+%s+(.*)')
end

function ClusterWindow:getClusterId(clusterName)
    -- Look through clusterTable to find clusterName
    local clusterId = nil
    for k, v in pairs(self.clustersTable) do
        if k == clusterName then
            clusterId = v[1]
            return clusterId
        end
    end
    if not clusterId then
        print("Error, no cluster id found for " .. clusterName)
    end

    return clusterId

end

function ClusterWindow:toggleClusterOnOff(clusterTable, onlyStart)
    local command
    if clusterTable[2] == "TERMINATED" then
        command = "databricks clusters start --no-wait " .. clusterTable[1]
        print("Starting cluster: " .. clusterTable[3])
    else
        if not onlyStart then
            command = "databricks clusters delete --no-wait " .. clusterTable[1]
            print("Stopping cluster: " .. clusterTable[3])
        end
    end

    if command then
        local result = vim.fn.system(command)
        if vim.v.shell_error ~= 0 then
            print("Error executing command: " .. command .. " Error was: " .. result)
        end
    end
end

--[[
Setup keymaps specifically for cluster window
]]
function ClusterWindow:clusterKeymaps()
    -- Load default keymaps
    self:keymaps()

    -- Key mappings for buffer control
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'h', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            vim.api.nvim_win_set_buf(self.win, self.parent)
        end,
    })

    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'l', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            vim.api.nvim_win_set_buf(self.win, self.child)
        end,
    })

    -- Private function to close windows
    function self:_closeClusterWindow()
        self:closeListOfBuffers()
        vim.api.nvim_del_augroup_by_id(self.augroup)
    end

    function self:_resetWindow(full)
        -- Get cluster info for the specific profile
        if full then
            DB_CLUSTERS_LIST = {}
        else
            self:getClusters(true)
        end
        self:_closeClusterWindow()
        vim.cmd("DBOpen")
    end

    function self:_startStopCluster(onlyStart)
        local clusterName = self:getClusterName()
        local clusterTable = self.clustersTable[clusterName]
        self:toggleClusterOnOff(clusterTable, onlyStart)
    end

    vim.api.nvim_buf_set_keymap(self.buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            ClusterSelectionState.profile = self.name
            ClusterSelectionState.name = self:getClusterName()
            print("Picked cluster: " .. ClusterSelectionState.name)
            self:_startStopCluster(true)
            self:_closeClusterWindow()
            ClusterSelectionState.clusterId = self:getClusterId(ClusterSelectionState.name)
        end,
    })

    vim.api.nvim_buf_set_keymap(self.buf, 'n', 's', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:_startStopCluster(false)
            self:_resetWindow(false)
        end,
    })

    -- Key mapping to re-draw the buffer
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'r', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:_resetWindow(false)
        end,
    })

    -- Key mapping to re-draw all the buffers
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'R', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:_resetWindow(true)
        end,
    })
end

function ClusterWindow:createClusterWindow(win, windows)
    -- Open window
    self.win = win or vim.api.nvim_open_win(self.buf, true, self.winOpts)
    self:setupClusterWindow(windows)
    return self.win
end

function ClusterWindow:setupClusterWindow(windows)
    -- Set cursor position
    vim.api.nvim_win_set_cursor(self.win, {self.headerLength+1, 0})
    -- Set buffer and window options
    vim.api.nvim_win_set_option(self.win, 'cursorline', true)
    vim.api.nvim_buf_set_option(self.buf, 'modifiable', false)
    self:setParentAndChildProfile(windows)
    self:clusterKeymaps()
end

-------------
-- Returns --
-------------

local M = {}

M.ClusterWindow = ClusterWindow
M.Window = Window

return M
