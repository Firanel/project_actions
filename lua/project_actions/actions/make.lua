local utils = require "project_actions.utils"

local function get_make_targets()
  -- get data
  local process = io.popen("make -qp 2> "..utils.null_file, "r")
  if not process then return {} end

  local targets = {}
  local index = 1
  for line in process:lines() do
    local target_string, after_colon = line:match "^(%w[^$#/\t=]*):(.?)"
    if target_string ~= nil and after_colon ~= "=" then
      for target in target_string:gmatch "[^ ]+" do
        if targets[target] == nil then -- no duplicates
          targets[target] = index
          index = index + 1
        end
      end
    end
  end
  process:close()

  local result = {}
  for target, i in pairs(targets) do
    result[i] = target
  end
  return result
end

local function make_run(found, _)
  local targets = get_make_targets()
  for i, target in ipairs(targets) do
    targets[i] = {
      name = target,
    }
  end
  table.insert(targets, 1, {
    name = "make",
    run = {
      prompt = "target",
      empty = true,
    }
  })
  return {
    title = "Make",
    cmd = string.format("!make -C '%s'", vim.fs.dirname(found)),
    values = targets,
  }
end

return make_run
