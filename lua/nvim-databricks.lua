local callable = require('modules/callable')
local utils = require('modules/utils')

local M = {}

M.setup = function(userOpts)

    -------------------------------
    -- Setup user configurations --
    -------------------------------

    -- Set default values if not provided
    local opts = userOpts or {}

    -- Databricks connection configuration file
    if opts.DBConfigFile == nil then opts.DBConfigFile = '~/.databrickscfg' end

    -- Floating window size
    if opts.width == nil then opts.width = math.floor(vim.o.columns * 0.9) end
    if opts.height == nil then opts.height = 20 end
    if opts.row == nil then opts.row = math.floor((vim.o.lines - opts.height) / 2) end
    if opts.col == nil then opts.col = math.ceil((vim.o.columns - opts.width) / 2) end

    -------------------------------
    -- Setup base configurations --
    -------------------------------

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

    -------------------------
    -- Setup nvim commands --
    -------------------------

    vim.api.nvim_create_user_command('DBOpen', function()
        callable.openWindow(opts)
    end, {})

    vim.api.nvim_create_user_command('DBRun', function()
        callable.runSelection()
    end, {})

    vim.api.nvim_create_user_command('DBPrintState', function()
        utils.printTable(ClusterSelectionState, "Cluster selection: ")
    end, {})

end



return M
