local json = require "json"
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local prompt_run = require "project_actions.utils".prompt_run

local function cargo_remove(telescope_opts)
  local fd = io.popen("cargo metadata --quiet --color never --format-version 1")
  if fd == nil then
    vim.notify("Cargo not found")
    return
  end
  local metadata = json.decode(fd:read "*a")
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
    cmd = "cargo",
    values = {
      -- Build Commands
      {
        name = "bench",
        run = function() prompt_run("benchname", "!cargo bench ", true) end
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
        run = function() prompt_run("args", "!cargo run -- ", true) end
      },
      {
        name = "rustc",
        run = function() prompt_run("rustc args", "!cargo rustc -- ", true) end
      },
      {
        name = "rustdoc",
        run = function() prompt_run("rustdoc args", "!cargo rustdoc -- ", true) end
      },
      { name = "test" },
      {
        name = "test name",
        run = function() prompt_run("test", "!cargo test ", true) end
      },
      {
        name = "report",
        run = function() prompt_run("type", "!cargo report ") end
      },
      -- Manifest Commands
      {
        name = "add",
        run = function() prompt_run("crate", "!cargo add ") end
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
        run = function() prompt_run("crate", "!cargo install ") end
      },
    },
  }
end

return cargo_run
