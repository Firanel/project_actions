local is_windows = vim.loop.os_uname().sysname:lower() == "windows"



local function prompt_run(prompt, cmd, allow_empty)
  vim.ui.input({
    prompt = prompt .. (allow_empty and " ?> " or " > "),
  }, function(input)
    if input and (allow_empty or not input:match "^[%s%c]*$") then
      vim.cmd(string.format(cmd, input))
    end
  end)
end

local function table_clone(t)
  local clone = {}
  for k, v in pairs(t) do
    clone[k] = v
  end
  return clone
end

local function do_in_dir(dir, func, ...)
  local uv = vim.loop or vim.uv
  local cwd = uv.cwd()
  if cwd and cwd ~= dir then
    uv.chdir(dir)
    local res = {func(...)}
    uv.chdir(cwd)
    return unpack(res)
  else
    return func(...)
  end
end

return {
  prompt_run = prompt_run,
  table_clone = table_clone,
  is_windows = is_windows,
  do_in_dir = do_in_dir,
  null_file = is_windows and "NUL" or "/dev/null",
}
