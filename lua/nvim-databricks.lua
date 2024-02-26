local M = {}

M.setup = function(userOpts)
    DBUtils = require('modules/utils')
    local callable = require('modules/callable')
    local async = require('modules/databricks_async')

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

    -- Set python version
    if opts.python == nil then opts.python = "python3.10" end

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

    -----------------------------------
    --      Run setup commands      --
    -- Only applies to python files --
    -----------------------------------

    vim.api.nvim_create_augroup("nvim-databricks-augroup", { clear = true })
    DB_CLUSTERS_LIST = {}
    vim.api.nvim_create_autocmd("FileType", {
        group = "nvim-databricks-augroup",
        pattern = "python",
        callback = function()
            DB_CLUSTERS_LIST = async.AsyncClusters.new(opts)
        end,
    })

    -------------------------
    -- Setup nvim commands --
    -------------------------

    vim.api.nvim_create_user_command('DBOpen', function()
        callable.openWindow(opts)
    end, {})

    vim.api.nvim_create_user_command('DBRun', function()
        callable.runSelection(opts)
    end, {})

    vim.api.nvim_create_user_command('DBPrintState', function()
        DBUtils.printTable(ClusterSelectionState, "Cluster selection: ")
    end, {})

end



return M
