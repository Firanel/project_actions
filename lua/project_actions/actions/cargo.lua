local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local prompt_run = require "project_actions.utils".prompt_run

local function cargo_remove(_, telescope_opts)
  local fd = io.popen("cargo metadata --quiet --color never --format-version 1")
  if fd == nil then
    vim.notify("Cargo not found")
    return
  end
  local metadata = vim.json.decode(fd:read "*a")
  fd:close()

  local crates = {}
  local root_node = metadata.resolve.root
  for _, node in ipairs(metadata.resolve.nodes) do
    if node.id == root_node then
      for _, crate in ipairs(node.deps) do
        table.insert(crates, crate.name)
      end
      break
    end
  end

  pickers.new(telescope_opts, {
    prompt_title = "Cargo remove",
    finder = finders.new_table {
      results = crates,
    },
    sorter = conf.generic_sorter(telescope_opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local crate = action_state.get_selected_entry().value
        vim.cmd("!cargo remove " .. crate)
      end)
      return true
    end
  }):find()
end

local function cargo_run(telescope_opts)
  return {
    title = "Cargo",
    cmd = "!cargo",
    values = {
      -- Build Commands
      {
        name = "bench",
        run = {
          prompt = "benchname",
          cmd = "!cargo bench %s",
          empty = true,
        }
      },
      { name = "build" },
      { name = "check" },
      { name = "clean" },
      { name = "doc" },
      { name = "fetch" },
      { name = "fix" },
      { name = "run" },
      {
        name = "run with",
        -- run = function() prompt_run("args", "!cargo run -- ", true) end
        run = {
          prompt = "args",
          cmd = "!cargo run -- %s",
          empty = true,
        }
      },
      {
        name = "rustc",
        run = {
          prompt = "rustc args",
          cmd = "!cargo rustc -- %s",
          empty = true,
        }
      },
      {
        name = "rustdoc",
        run = {
          prompt = "rustdoc args",
          cmd = "!cargo rustdoc -- %s",
          empty = true,
        }
      },
      { name = "test" },
      {
        name = "test name",
        run = {
          prompt = "test",
          cmd = "!cargo test %s",
          empty = true,
        }
      },
      {
        name = "report",
        run = {
          prompt = "type",
          cmd = "!cargo report %s",
          empty = true,
        }
      },
      -- Manifest Commands
      {
        name = "add",
        run = {
          prompt = "crate",
          cmd = "!cargo add %s",
        }
      },
      {
        name = "remove",
        run = function() cargo_remove(telescope_opts) end
      },
      { name = "update" },
      { name = "fix" },
      -- Package Commands
      {
        name = "install",
        run = {
          prompt = "crate",
          cmd = "!cargo install %s",
        }
      },
    },
  }
end

return cargo_run
