local M = {}

M.openBuffer = require('modules/buffer').openBuffer

M.setup = function(userOpts)
    -- Set default values if not provided
    local opts = userOpts or {}

    if opts.configFile == nil then opts.configFile = '~/.databrickscfg' end

    if opts.headerLength == nil then opts.headerLength = 4 end
    if opts.bufferListLenght == nil then opts.bufferListLenght = 3 end

    if opts.width == nil then opts.width = math.floor(vim.o.columns * 0.9) end
    if opts.height == nil then opts.height = 20 end
    if opts.row == nil then opts.row = math.floor((vim.o.lines - opts.height) / 2) end
    if opts.col == nil then opts.col = math.ceil((vim.o.columns - opts.width) / 2) end

    -- Create the floating window
    opts.winOpts = {
        relative = 'editor',
        width = opts.width,
        height = opts.height,
        row = opts.row,
        col = opts.col,
        style = 'minimal',
        border = 'rounded',
    }


    vim.api.nvim_create_user_command('DBOpen', function()
        M.openBuffer(opts)
    end, {})

end



return M
