local is_windows = require "project_actions.utils" .is_windows

local function gradle_run(_)
  local cmd = is_windows() and ".\\gradlew.bat" or "./gradlew"

  local tasks_out = assert(io.popen(string.format("%s tasks --all 2> /dev/null", cmd), "r"))
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
