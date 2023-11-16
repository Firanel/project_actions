local function prompt_run(prompt, run_prefix, allow_empty)
  vim.ui.input({
    prompt = prompt .. (allow_empty and " ?> " or " > "),
  }, function(input)
    if input and (allow_empty or not input:match "^[%s%c]*$") then
      vim.cmd(run_prefix .. input)
    end
  end)
end

local function table_keys(t)
  local keys = {}
  for key, _ in pairs(t) do
    table.insert(keys, key)
  end
  return keys
end

local function table_values(t)
  local values = {}
  for _, value in pairs(t) do
    table.insert(values, value)
  end
  return values
end

local function table_clone(t)
  local clone = {}
  for k, v in pairs(t) do
    clone[k] = v
  end
  return clone
end

return {
  prompt_run = prompt_run,
  table_keys = table_keys,
  table_values = table_values,
  table_clone = table_clone,
}
