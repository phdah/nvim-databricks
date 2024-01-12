<h1 align="center">
  nvim-databricks (0.2.0-beta)
</h1>
<p align="center">
A simple, minimalistic, easily plugin to work with Databricks locally
</p>

<p align="center">
nvim-databricks example cluster view
</p>

![Demo Image](https://github.com/phdah/nvim-databricks/raw/main/images/demo.png)

<!-- badges: start -->
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/phdah/nvim-databricks/blob/main/LICENSE)
<!-- badges: end -->

## Requirements

- Neovim 0.X
- `Databricks connect`, [docs](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/databricks-connect/python/)
- `Databricks CLI`, follow the [docs](https://docs.databricks.com/en/dev-tools/cli/install.html) for installation, and setup your `~/.databrickscfg` file like
```bash
[DEFAULT]
host = <your_host>
token = <your_token>
cluster_id = <your_cluster_id>
org_id = <your_org_id>
jobs-api-version = 2.1

[other_profile]
...
```


## Installation

Use your favorite package manager, e.g., `packer`:
````lua
use {'phdah/nvim-databricks'}
````
and in your `init.lua`, put
````lua
require('nvim-databricks').setup()
````

## Configurations

For adding config, copy these default
````lua
require('buff-statusline').setup({
    DBConfigFile = '~/.databrickscfg', -- Databricks connect config file
    python = 'python3.10', -- Specify what Python to use
})
````
> **_NOTE:_** The values above are the defaults, so if this is what you want, just leave the setup empty.

## Using
Here are the functions available to use

| Command | Description |
| :--- | --- |
| `DBOpen` | Opens a list of clusters for all of the profiles setup in the configuration file. Choose a cluster, and it will update the plugin state, hence using that cluster for all following runs of the script when using `DBRun`. |
| `DBRun` | Run your currently open Python file, using the selected `profile` and `cluster` from the `DBOpen` command. If no selection has been made, this will use the `DEFAULT` profile from your config. |
| `DBPrintState` | Print the current selected; `profile`, `cluster id` and `cluster name`. |


## Remapping in Lua
````lua
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBOpen')
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBRun')
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBPrintState')
````

## Roadmap

| Feature | Status |
| --- | --- |
| Tabs for workspaces | ✅ |
| Setup workspace specific output | ✅ |
| Build a `run` module, to utelize lua in memory variables for cluster choosing | ✅ |
| Add `nerd` fonts images for cluster status etc | 🟨 |
| Optimize window opening by `persisting` buffers | 🟨 |
| Optimize window using `asynchronous` Databricks API calls | 🟨 |

