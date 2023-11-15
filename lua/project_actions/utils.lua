local function prompt_run(prompt, run_prefix, allow_empty)
  vim.ui.input({
    prompt = prompt .. (allow_empty and " ?> " or " > "),
  }, function(input)
    if input and (allow_empty or not input:match "^[%s%c]*$") then
      vim.cmd(run_prefix .. input)
    end
  end)
end

return {
  prompt_run = prompt_run,
}
