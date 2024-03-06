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

    -- Set python version
    if opts.python == nil then opts.python = "python3.10" end

    -- Cluster state icons
    if opts.states == nil then opts.states = {
        terminated = " ■        ",
        running = " ▶        ",
        pending = " ...      ",
        terminating = " ■        ",
    } end

    -------------------------------
    -- Setup base configurations --
    -------------------------------

    --[[
    Create the floating window
    The height and width is dynamicall
    set for each window created.
    ]]
    opts.winOpts = {
        relative = 'editor',
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
        callable.openClusterWindow(opts)
    end, {})

    vim.api.nvim_create_user_command('DBRun', function()
        callable.runSelection(opts)
    end, {})

    vim.api.nvim_create_user_command('DBRunOpen', function()
        callable.runOutputOpen(opts)
    end, {})

    vim.api.nvim_create_user_command('DBPrintState', function()
        DBUtils.printTable(ClusterSelectionState, "Cluster selection: ")
    end, {})

end



return M
