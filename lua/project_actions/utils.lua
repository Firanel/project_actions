local function prompt_run(prompt, run_prefix, allow_empty)
  vim.ui.input({
    prompt = prompt .. (allow_empty and " ?> " or " > "),
  }, function(input)
    if input and (allow_empty or not input:match "^[%s%c]*$") then
      vim.cmd(run_prefix .. " " .. input)
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

local function is_windows()
  return package.config:sub(1, 1) == "\\"
end

return {
  prompt_run = prompt_run,
  table_clone = table_clone,
  is_windows = is_windows,
}
