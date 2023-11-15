# Project specific actions for neovim

Shows a telescope window with project specific actions (like `npm install`).

Supported:
- `cargo`
- `npm`
- `make`

## Install

Install with your favorite package manager.
Requires [telescope](https://github.com/nvim-telescope/telescope.nvim).

Lazy:
```lua
require "lazy" .setup {
    {
        "firanel/project_actions",
        dependencies = {
            "nvim-telescope/telescope.nvim",
        },
        lazy = true,
    },
}
```

## Configuration

None at the moment.

## Usage

All functions operate on the current working directory.
You can use [project.nvim](https://github.com/ahmedkhalf/project.nvim)
to automatically set your working directory to your project root.

```lua
require "project_actions" .show_actions()
```

## Features

### Cargo

Supports all basic cargo commands like `cargo add` and `cargo run`.

### Make

Attempts to read build targets from makefile.

Also shows `make` option for user specified targets.

### NPM

Supports basic npm functions like `npm install`
and can run scripts from `package.json`.

## Features for single files

### Lua

Run the current file.

### JavaScript

Run the current file with node.
