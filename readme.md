# Project and file specific actions for neovim

Shows a telescope window with project and file specific actions
(like `npm install`).

Supported project types:
- `cargo`
- `npm`
- `make`
- `gradle`

Supported file types:
- `lua`
- `javascript`
- `typescript` (only with bun)

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

Use the default configuration (calling setup is optional) unless you want to
extend the functionality.

Options object:
- `project_actions`: list of project actions to support
- `file_actions`: list of file actions to support

Builtin actions are lazy loaded.

### Project actions

Set `extends = true` to extend default options instead of overriding them.
The elements of the `project_actions` array are either names of builtin
actions or objects of the form:
- `condition`: name of a file which must be present in the project root,
    list of files
    or a function which should return a found file
- `load`: function which returns a project action object
    or name of a module which exports said function.
    The function is called with 2 parameters:
    - The found value (returned from the condition)
    - Telescope options
- `exclude_file_actions` (optional): list of filetypes[^1] for which to disable
    file actions

Project action object:
- `title`: title for telescope window
- `cmd` (optional): base command for entries without `run` specified
- `values`: telescope entries as a list of entry objects

Entry object:
- `name`: Name of the entry
- `run` (optional): function to call, command as string
    or run prompt object,
    if none is given uses `string.format("%s %s", project.cmd, entry.name)`
    as command string

Run prompt object:
- `prompt`: Prompt text
- `run` (optional): see entry object run (without run prompt object)
- `empty` (optional): boolean whether to allow empty argument

### File actions

Set `extends = true` to extend default options instead of overriding them.
Elements should be either names of builtin actions or a key value pair,
where the key is the filetype[^1] and the value is a function which returns
a list of entry objects (see project actions) or the name of a module
which exports said function.

To extend a builtin filetype you will need to merge it into your actions manually.
For example:
```lua
function my_js_file_actions()
    -- get defaults
    local actions = require "project_actions.file_actions.javascript" ()
    -- add new
    table.insert(actions, {
        name = "Node: run2",
        run = function(buf)
          vim.cmd(string.format(":!node '%s'", vim.api.nvim_buf_get_name(buf)))
        end
    })
    return actions
end
```
Default file actions can be imported from
`project_actions.file_actions.<filetype>`.

[^1]: Filetype means nvim file type not extension.

### Example

```lua
require "project_actions" .setup {
    project_actions = {
        extends = true, -- extend default configuration
        "cargo", -- include default cargo actions (redundant with extends)
        { -- Adding alternative npm actions
            condition = "package.json",
            load = "my_lib.project_actions.npm",
            exclude_file_actions = { "javascript" }, -- optional
        },
    },
    file_actions = {
        "javascript",
        "lua" = "my_lib.file_actions.lua_actions",
        "typescript" = function ()
            -- get my typescript actions
        end
    },
}
```

## Usage

All functions operate on the current working directory
and assume that it is the project root.
You can use [project.nvim](https://github.com/ahmedkhalf/project.nvim)
to automatically set your working directory to your project root.

```lua
local show_project_actions = require "project_actions" .show_actions

vim.keymap.set("n", "<Leader>a", show_project_actions)
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

### Gradle

Shows all tasks from `gradlew tasks --all`.
Running this the first time can take very long.

## Features for single files

### Lua

Run the current file.

### JavaScript

Run the current file with node or bun.

### Typescript

Run the current file with bun.
