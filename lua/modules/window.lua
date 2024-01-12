local utils = require('modules/utils')
local Tab = require('modules/buffers').Tab

------------
-- Window --
------------

local Window = {}
Window.__index = Window
setmetatable(Window, Tab)

function Window.new(opts, name, profiles)
    local self = setmetatable({}, Window)
    self.name = name
    self.winOpts = opts.winOpts

    -- Run helper functions
    self:createTabs(profiles)
    self:createBuffer()
    self:getClusters()
    self.windowLenght = self.headerLength + self.clusterLenght

    -- Setup window
    self:populate()
    self:movementRestriction()

    return self
end

function Window:populate()
    -- TODO: check if the lines can all go in one table
    -- Set header
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, {self.header, ""})
    -- Set lines in the buffer
    vim.api.nvim_buf_set_lines(self.buf, 2, -1, false, {self.columns, self.boarder})
    vim.api.nvim_buf_set_lines(self.buf, self.headerLength, -1, false, self.clusters)
    -- Static tabs line
    vim.api.nvim_buf_set_lines(self.buf, self.windowLenght, self.windowLenght, false, {self.boarder, self.tabs[self.name]})
end

function Window:movementRestriction()
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

function Window:setParentAndChildProfile(bufferState)
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

function Window:closeListOfBuffers()
    for _, buf in ipairs({self.buf, self.parent, self.child}) do
        -- Close each buffer if it's valid
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end

function Window:getClusterName()
    -- Get the current line number
    local lineNum = vim.api.nvim_win_get_cursor(self.win)[1]
    -- Get the line's content
    local lineContent = vim.api.nvim_buf_get_lines(self.buf, lineNum - 1, lineNum, false)[1]

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


function Window.getClusterId(clusterName)
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

function Window:keymaps()
    -- Key mappings for buffer control
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'h', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            utils.printTable({self.win, self.parent})
            vim.api.nvim_win_set_buf(self.win, self.parent)
        end,
    })

    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'l', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            utils.printTable({self.win, self.child})
            vim.api.nvim_win_set_buf(self.win, self.child)
        end,
    })

    vim.api.nvim_buf_set_keymap(self.buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            self.getClusterId(self:getClusterName())
        end,
    })

    -- Key mapping to close the buffer
    vim.api.nvim_buf_set_keymap(self.buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            self:closeListOfBuffers()
            vim.api.nvim_del_augroup_by_id(self.augroup)
        end,
    })
end

function Window:createWindow(win, windows)
    -- Open window
    self.win = win or vim.api.nvim_open_win(self.buf, true, self.winOpts)
    self:setupWindow(windows)
    return self.win
end

function Window:setupWindow(windows)
    -- Set cursor position
    vim.api.nvim_win_set_cursor(self.win, {self.headerLength+1, 0})
    -- Set buffer and window options
    vim.api.nvim_win_set_option(self.win, 'cursorline', true)
    vim.api.nvim_buf_set_option(self.buf, 'modifiable', false)
    self:setParentAndChildProfile(windows)
    self:keymaps()
end

-------------
-- Returns --
-------------

local M = {}

M.Window = Window

return M