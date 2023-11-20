local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function npm_remove(package_json, telescope_opts)
  local packages = {}
  for name, _ in pairs(package_json.dependencies or {}) do
    table.insert(packages, name)
  end
  for name, _ in pairs(package_json.devDependencies or {}) do
    table.insert(packages, name)
  end
  for name, _ in pairs(package_json.peerDependencies or {}) do
    table.insert(packages, name)
  end

  pickers.new(telescope_opts, {
    prompt_title = "NPM remove",
    finder = finders.new_table {
      results = packages,
    },
    sorter = conf.generic_sorter(telescope_opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local package = action_state.get_selected_entry().value
        vim.cmd("!npm remove " .. package)
      end)
      return true
    end
  }):find()
end

local function npm_run(found, telescope_opts)
  local fd = io.open(found, "r")
  if fd == nil then
    error("Couldn't open package.json")
  end

  local package_json = vim.json.decode(fd:read "*a")
  fd:close()

  local scripts = {
    {
      name = "install",
      run = {
        prompt = "package",
        empty = true,
      }
    },
    {
      name = "install -D",
      run = {
        prompt = "package",
      }
    },
    {
      name = "remove",
      run = function()
        npm_remove(package_json, telescope_opts)
      end
    },
  }

  for script, _ in pairs(package_json.scripts or {}) do
    table.insert(scripts, {
      name = string.format("run: %s", script),
      run = string.format("!npm run %s", script),
    })
  end

  return {
    title = "NPM",
    cmd = "!npm",
    values = scripts,
    root = vim.fs.dirname(found)
  }
end

return npm_run
