local M = {}

M.populateBuffer = require('modules/configBuffer').populateBuffer
M.restrictBufferMovement = require('modules/configBuffer').restrictBufferMovement
M.getClusterName = require('modules/getClusterId').getClusterName
M.getClusterId = require('modules/getClusterId').getClusterId
M.setCluster = require('modules/setCluster').setCluster
M.closeListOfBuffers = require('modules/bufferUtils').closeListOfBuffers
M.strBufferList = require('modules/bufferUtils').strBufferList

M.bufferStatus = {
    bufferList = {},
    win = nil,
    currentBufferIndex = nil,
    augroup = nil
}

M.createBuffer = function(opts)
    local buf
    buf = M.populateBuffer(opts, M.bufferStatus)

    table.insert(M.bufferStatus.bufferList, buf)
end

M.configBuffer = function(opts, buf)
    vim.api.nvim_win_set_cursor(M.bufferStatus.win, {opts.headerLength+1, 0})

    -- Set buffer and window options
    vim.api.nvim_win_set_option(M.bufferStatus.win, 'cursorline', true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Key mappings for buffer control
    vim.api.nvim_buf_set_keymap(buf, 'n', 'h', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            M.bufferStatus.currentBufferIndex = (M.bufferStatus.currentBufferIndex - 2) % #M.bufferStatus.bufferList + 1
            local newBuf = M.bufferStatus.bufferList[M.bufferStatus.currentBufferIndex]
            vim.api.nvim_win_set_buf(M.bufferStatus.win, newBuf)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, 'n', 'l', '', {
        noremap = true,
        silent = true,
        callback = function()
            -- Switch to the previous buffer
            M.bufferStatus.currentBufferIndex = (M.bufferStatus.currentBufferIndex % #M.bufferStatus.bufferList) + 1
            local newBuf = M.bufferStatus.bufferList[M.bufferStatus.currentBufferIndex]
            vim.api.nvim_win_set_buf(M.bufferStatus.win, newBuf)
        end,
    })

    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            M.setCluster(M.getClusterId(M.getClusterName(M.bufferStatus.win, buf)), opts)
        end,
    })

    -- Key mapping to close the buffer
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            M.bufferStatus.bufferList = M.closeListOfBuffers(M.bufferStatus.bufferList)
            vim.api.nvim_del_augroup_by_id(M.bufferStatus.augroup)
        end,
    })

end

M.openBuffer = function(opts)
    -- Create augroup
    M.bufferStatus.augroup = vim.api.nvim_create_augroup('LimitCursorMovement', { clear = true })

    -- Create buffers
    for i = 1 , opts.bufferListLenght do
        M.bufferStatus.currentBufferIndex = i
        M.createBuffer(opts)
    end

    -- Create window
    M.bufferStatus.currentBufferIndex = 1
    local initialBuf = M.bufferStatus.bufferList[M.bufferStatus.currentBufferIndex]
    M.bufferStatus.win = vim.api.nvim_open_win(initialBuf, true, opts.winOpts)

    -- Configure buffers
    for _, buf in ipairs(M.bufferStatus.bufferList) do
        M.configBuffer(opts, buf)
    end

end

return M
