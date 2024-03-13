<h1 align="center">
  nvim-databricks (0.2.0-beta)
</h1>
<p align="center">
A simple, minimalistic, easy plugin to work with Databricks & Pyspark locally
</p>

<p align="center">
nvim-databricks example cluster view
</p>

![Demo Image](https://github.com/phdah/nvim-databricks/raw/main/images/demo_clusters.png)

<p align="center">
nvim-databricks example run output
</p>

![Demo Image](https://github.com/phdah/nvim-databricks/raw/main/images/demo_run.png)

<!-- badges: start -->
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/phdah/nvim-databricks/blob/main/LICENSE)
<!-- badges: end -->

## Requirements

- Neovim `0.9.2`
- `jq` cli, install for your specific OS
- `Databricks connect`, [docs](https://learn.microsoft.com/en-us/azure/databricks/dev-tools/databricks-connect/python/)
- `Databricks CLI==v0.212.2`, follow the [docs](https://docs.databricks.com/en/dev-tools/cli/install.html) for installation, and setup your `~/.databrickscfg` file like:
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

For adding config, add a setup input like
````lua
require('buff-statusline').setup({
    DBConfigFile = '~/.databrickscfg', -- Set path to Databricks connect config file
    python = 'python3.10', -- Set Python version for DBRun
})
````
> **_NOTE:_** The values above are the defaults, so if this is what you want, just leave the setup empty.

## Using
Here are the functions available to use

| Command | Description |
| :--- | --- |
| `DBOpen` | Opens a list of clusters for all of the profiles setup in the configuration file. Choose a cluster, and it will update the plugin state, hence using that cluster for all following runs of a Python script when using `DBRun`, throughout the current neovim session. |
| `DBRun` | Runs your currently open Python neovim buffer, using the selected `profile` and `cluster` from the `DBOpen` command. If no selection has been made, this will use the `DEFAULT` profile from your config, or specified environemental variables `DATABRICKS_CONFIG_PROFILE` and `DATABRICKS_CLUSTER_ID`. |
| `DBPrintState` | Print the current selected; `profile`, `cluster id` and `cluster name`. |


## Remapping in Lua
````lua
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBOpen')
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBRun')
vim.api.nvim_set_keymap('n', '<new_keymap>', ':DBPrintState')
````

## Limitations
* Currently only supports `Pyspark`.

## Roadmap

| Feature | Status |
| --- | --- |
| Tabs for workspaces | ✅ |
| Setup workspace specific output | ✅ |
| Build a `run` module, to utelize lua in memory variables for cluster choosing | ✅ |
| Optimize window opening by `persisting` buffers | ✅ |
| Optimize window using `asynchronous` Databricks API calls | ✅ |
| Add `nerd` fonts images for cluster status etc | ✅ |
| Add a complete UI, which displays graphical objects | 🟨 |
| Add graphical objects to indicate, e.g., selected cluster and its state | 🟨 |
| Add file type check for how to run with `DBRun`, e.g., if `.py` use `python` | 🟨 |
| Add a `y` key for yanking all relevant output from the `DBRun` output window | 🟨 |
| Add a `h` key for `help`, in which we can see all the keymaps. The "list" of them is too long now | 🟨 |

## Known bugs

| Bugs | Status | Solution |
| --- | --- | --- |
| JSON output of `databricks clusters list` is different between versions, hence, parsing is not working. | ✅ | Using the standard of `Databricks CLI v0.212.2`, which outputs a list of JSONs |
