local prompt_run = require "project_actions.utils" .prompt_run

local lua_actions = {
  {
    name = "lua: run",
    run = function(buf)
      vim.cmd(string.format(":!lua '%s'", vim.api.nvim_buf_get_name(buf)))
    end,
  },
  {
    name = "lua: run with arguments",
    run = function(buf)
      local cmd = string.format(":!lua '%s'", vim.api.nvim_buf_get_name(buf))
      prompt_run(cmd, cmd, true)
    end,
  },
}

return function() return lua_actions end
