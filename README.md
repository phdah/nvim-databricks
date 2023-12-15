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

For adding configs, copy these default
````lua
require('buff-statusline').setup({
    configFile = '~/.databrickscfg', -- Databricks connect config file
})
````

## Useing
> **_NOTE:_**  This plugin is used to ineractively configure your `Databricks Connect` setup, but for running your code, that is sepperate.
Here are the functions available to use

| Command | Description |
| :--- | --- |
| `DBOpen` | Opens a list of clusters for the current workspace. Choose one, and it will update the config in `~/.databrickscfg`, hence using that cluster for all following runs of the script. |


## Remapping in lua
````lua
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBOpen')
````

## Roadmap

| Feature | Status |
| --- | --- |
| Tabs for workspaces | ✅ |
| Setup workspace specific output | 🟨 |
| Build a `run` module, to utelize lua in memory variables for cluster choosing | 🟨 |
| Add nerd font images for cluster status etc | 🟨 |

