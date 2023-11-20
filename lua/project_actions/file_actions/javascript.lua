local prompt_run = require "project_actions.utils" .prompt_run

local js_actions = {
  {
    name = "node: run",
    run = function(buf)
      vim.cmd(string.format("!node '%s'", vim.api.nvim_buf_get_name(buf)))
    end
  },
  {
    name = "node: run with arguments",
    run = function(buf)
      local cmd = string.format("!node '%s'", vim.api.nvim_buf_get_name(buf))
      prompt_run(cmd, cmd, true)
    end,
  },
}

require "project_actions.file_actions.common.bun" (js_actions)

return function() return js_actions end
