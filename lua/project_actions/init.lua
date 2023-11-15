local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require "telescope.config".values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local function tbl_push(tbl, ...)
  for _, value in ipairs{...} do
    table.insert(tbl, value)
  end
end

local function tbl_position(tbl, needle, tbl_as_patterns)
  for i, value in ipairs(tbl) do
    if tbl_as_patterns and needle:match(value) or value == needle then
      return i
    end
  end
  return nil
end

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

local function show_actions(telescope_opts, buffer)
  telescope_opts = telescope_opts or require "telescope.themes".get_dropdown {}
  buffer = buffer or vim.inspect_pos().buffer

  local picker_groups = {}
  local exclude = {}

  for name, _ in vim.fs.dir "." do
    name = name:lower()
    if name == "package.json" then
      table.insert(picker_groups,
        require "project_actions.actions.npm" (name, telescope_opts))
      tbl_push(exclude, "javascript", "typescript")
    elseif name == "cargo.toml" then
      table.insert(picker_groups,
        require "project_actions.actions.cargo" (telescope_opts))
      table.insert(exclude, "rust")
    elseif name == "makefile" then
      table.insert(picker_groups,
        require "project_actions.actions.make" (telescope_opts))
    end
  end

  local filetype = vim.filetype.match { buf = 0 }
  if nil == tbl_position(exclude, filetype) then
    if filetype == "lua" then
      tbl_push(picker_groups, unpack(require "project_actions.file_actions.lua"))
    elseif filetype == "javascript" then
      tbl_push(picker_groups, unpack(require "project_actions.file_actions.js"))
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

return {
  show_actions = show_actions,
}
