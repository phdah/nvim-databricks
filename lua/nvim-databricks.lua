local M = {}

M.createBuffer = require('modules/buffer').createBuffer

M.setup = function(userOpts)
    -- Set default values if not provided
    local opts = userOpts or {}

    if opts.configFile == nil then opts.configFile = '~/.databrickscfg' end

    vim.api.nvim_create_user_command('DBOpen', function()
        M.createBuffer(opts.configFile)
    end, {})

end



return M
