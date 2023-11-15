# Project specific actions for neovim

Shows a telescope window with project specific actions (like `npm install`).

Supported:
- `cargo` for rust
- `npm` for ECMAScript
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
    },
}
```

## Configuration

None at the moment.

## Usage

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

Run current file with node.
