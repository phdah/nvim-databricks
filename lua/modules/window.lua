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

function Window:config()
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
    self.augroup = vim.api.nvim_create_augroup('LimitCursorMovement', { clear = true })
    vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI'}, {
        group = self.augroup,
        buffer = self.buf,
        callback = function()
            local cursor = vim.api.nvim_get_cursor(0)
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

-- function Window:keymaps()
--     -- Key mappings for buffer control
--     vim.api.nvim_buf_set_keymap(buf, 'n', 'h', '', {
--         noremap = true,
--         silent = true,
--         callback = function()
--             -- Switch to the previous buffer
--             M.bufferStatus.currentBufferIndex = (M.bufferStatus.currentBufferIndex - 2) % #M.bufferStatus.bufferList + 1
--             local newBuf = M.bufferStatus.bufferList[M.bufferStatus.currentBufferIndex]
--             vim.api.nvim_win_set_buf(M.bufferStatus.win, newBuf)
--         end,
--     })

--     vim.api.nvim_buf_set_keymap(buf, 'n', 'l', '', {
--         noremap = true,
--         silent = true,
--         callback = function()
--             -- Switch to the previous buffer
--             M.bufferStatus.currentBufferIndex = (M.bufferStatus.currentBufferIndex % #M.bufferStatus.bufferList) + 1
--             local newBuf = M.bufferStatus.bufferList[M.bufferStatus.currentBufferIndex]
--             vim.api.nvim_win_set_buf(M.bufferStatus.win, newBuf)
--         end,
--     })

--     vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
--         noremap = true,
--         silent = true,
--         callback = function()
--             M.setCluster(M.getClusterId(M.getClusterName(M.bufferStatus.win, buf)), opts)
--         end,
--     })

--     -- Key mapping to close the buffer
--     vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
--         noremap = true,
--         silent = true,
--         callback = function()
--             M.bufferStatus.bufferList = M.closeListOfBuffers(M.bufferStatus.bufferList)
--             vim.api.nvim_del_augroup_by_id(M.bufferStatus.augroup)
--         end,
--     })
-- end


function Window:createWindow()
    -- Open window
    self.win = vim.api.nvim_open_win(self.buf, true, self.winOpts)
    -- Set cursor position
    vim.api.nvim_win_set_cursor(self.win, {self.headerLength+1, 0})
    -- Set buffer and window options
    vim.api.nvim_win_set_option(self.win, 'cursorline', true)
    vim.api.nvim_buf_set_option(self.buf, 'modifiable', false)
end

-------------
-- Returns --
-------------

local M = {}

M.Window = Window

return M
