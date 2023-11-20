local utils = require "project_actions.utils"

local function gradle_run(_, _)
  local cmd = utils.is_windows and ".\\gradlew.bat" or "./gradlew"

  local tasks_out = assert(io.popen(
    string.format("%s tasks --all 2> %s",
    cmd,
    utils.null_file
  ), "r"))
  local tasks = {}
  for line in tasks_out:lines() do
    local desc, name = line:match "^(([%w:]+) %- .+)$"
    if name then
      table.insert(tasks, {
        name = desc,
        run = string.format("!%s %s", cmd, name),
      })
    end
  end

  return {
    title = "Gradle",
    cmd = cmd,
    values = tasks,
  }
end

return gradle_run
