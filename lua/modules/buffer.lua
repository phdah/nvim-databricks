local M = {}

M.populateBuffer = require('modules/configBuffer').populateBuffer
M.restrictBufferMovement = require('modules/configBuffer').restrictBufferMovement
M.getClusterName = require('modules/getClusterId').getClusterName
M.getClusterId = require('modules/getClusterId').getClusterId
M.setCluster = require('modules/setCluster').setCluster


M.createBuffer = function(defaultConfigFile)
    local headerLength = 3

    local buf = M.populateBuffer(headerLength)
    -- Define the floating window size and position
    local width = math.floor(vim.o.columns * 0.9)
    local height = 20
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.ceil((vim.o.columns - width) / 2)

    -- Create the floating window
    local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    local augroup = M.restrictBufferMovement(headerLength, buf)

    -- Set the cursor start
    vim.api.nvim_win_set_cursor(win, {headerLength+1, 0})

    -- Set buffer and window options
    vim.api.nvim_win_set_option(win, 'cursorline', true)
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    -- vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
        noremap = true,
        silent = true,
        callback = function()
            M.setCluster(M.getClusterId(M.getClusterName(win, buf)), defaultConfigFile)
        end,
    })

    -- Key mapping to close the buffer
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_del_augroup_by_id(augroup)
        end,
    })

end

return M
