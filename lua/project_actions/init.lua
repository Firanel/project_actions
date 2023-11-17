local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local utils = require "project_actions.utils"

--#region Configuration

local project_actions_map = {
  npm = {
    condition = "package.json",
    load = "project_actions.actions.npm",
    exclude_file_actions = { "javascript", "typescript" },
  },
  cargo = {
    condition = "cargo.toml",
    load = "project_actions.actions.cargo",
    exclude_file_actions = { "rust" },
  },
  make = {
    condition = "makefile",
    load = "project_actions.actions.make",
  },
  gradle = {
    condition = ".gradle",
    load = "project_actions.actions.gradle",
  },
}

local file_actions_map = {
  javascript = "project_actions.file_actions.javascript",
  typescript = "project_actions.file_actions.typescript",
  lua = "project_actions.file_actions.lua",
}

local default_options = {
  file_actions = file_actions_map,
  project_actions = utils.table_values(project_actions_map),
}

local global_options = utils.table_clone(default_options)

--#endregion
--#region private functions

local function run_value(value, cmd, buffer)
  local run_type = type(value.run)
  if run_type == "nil" then
    vim.cmd(string.format("!%s %s", cmd or "", value.name))
  elseif run_type == "string" then
    vim.cmd(value.run)
  else
    value.run(buffer)
  end
end

local function show_picker(picker, telescope_opts, buffer)
  pickers.new(telescope_opts, {
    prompt_title = picker.title,
    finder = finders.new_table {
      results = picker.values,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.name,
          ordinal = entry.name,
        }
      end,
    },
    sorter = conf.generic_sorter(telescope_opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local value = action_state.get_selected_entry().value
        run_value(value, picker.cmd, buffer)
      end)
      return true
    end,
  }):find()
end

--#endregion
--#region public functions

local function setup(opts)
  if not opts then return end

  local project_actions = opts["project_actions"]
  if project_actions then
    local pa_option = project_actions["extend"]
      and default_options["project_actions"]
      or {}
    for _, action in ipairs(project_actions) do
      table.insert(pa_option, type(action) == "string"
        and project_actions_map[action]
        or action)
    end
    global_options["project_actions"] = pa_option
  end

  local file_actions = opts["file_actions"]
  if file_actions then
    local fa_option = file_actions["extend"]
      and default_options["file_actions"]
      or {}
    for filetype, source in pairs(file_actions) do
      if type(filetype) == "number" then
        fa_option[source] = file_actions_map[source]
      elseif filetype ~= "extend" then
        fa_option[filetype] = source
      end
    end
    global_options["file_actions"] = fa_option
  end
end

local function show_actions(telescope_opts, buffer)
  telescope_opts = telescope_opts or require "telescope.themes".get_dropdown {}
  buffer = buffer or vim.inspect_pos().buffer

  local picker_groups = {}
  local exclude = {}

  local folder = {}
  for name, _ in vim.fs.dir "." do
    folder[name] = true
  end

  for _, action in ipairs(global_options["project_actions"]) do
    -- error(vim.inspect(action))
    local condition = action["condition"]
    if type(condition) ~= "string"
      and condition(folder) == true
      or folder[condition] == true
    then
      local load = action["load"]
      local exclude_files = action["exclude_file_action"]
      table.insert(picker_groups,
        type(load) == "string" and require(load)() or load())
      if exclude_files ~= nil then
        for i = 1, #exclude_files do
          exclude[exclude_files[i]] = true
        end
      end
    end
  end

  local filetype = vim.filetype.match { buf = 0 }
  local file_action = global_options["file_actions"][filetype]
  if exclude[filetype] ~= true and file_action ~= nil then
    for _, action in ipairs(type(file_action) == "string"
      and require(file_action)()
      or file_action())
    do
      table.insert(picker_groups, action)
    end
  end

  if #picker_groups == 0 then
    print "No actions available"
  elseif #picker_groups == 1 and not picker_groups[1].name then
    show_picker(picker_groups[1], telescope_opts, buffer)
  else
    pickers.new(telescope_opts, {
      prompt_title = "Actions",
      finder = finders.new_table {
        results = picker_groups,
        entry_maker = function(entry)
          local name = entry.name or entry.title
          return {
            value = entry,
            display = name,
            ordinal = name,
          }
        end,
      },
      sorter = conf.generic_sorter(telescope_opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local value = action_state.get_selected_entry().value
          if value.name then
            run_value(value, nil, buffer)
          else
            show_picker(value, telescope_opts, buffer)
          end
        end)
        return true
      end,
    }):find()
  end
end

--#endregion

return {
  show_actions = show_actions,
  setup = setup,
}
