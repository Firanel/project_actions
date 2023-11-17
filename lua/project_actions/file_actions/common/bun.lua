local prompt_run = require "project_actions.utils" .prompt_run

return function(actions)
  if os.execute("bun --version 2> /dev/null") then
    table.insert(actions, {
      name = "bun: run",
      run = function(buf)
        vim.cmd(string.format(":!bun run '%s'", vim.api.nvim_buf_get_name(buf)))
      end
    })
    table.insert(actions, {
      name = "bun: run with arguments",
      run = function(buf)
        local cmd = string.format(":!bun run '%s'", vim.api.nvim_buf_get_name(buf))
        prompt_run(cmd, cmd, true)
      end
    })
    table.insert(actions, {
      name = "bun: watch",
      run = function(buf)
        vim.cmd(string.format(":!bun --watch run '%s'", vim.api.nvim_buf_get_name(buf)))
      end
    })
    table.insert(actions, {
      name = "bun: watch with arguments",
      run = function(buf)
        local cmd = string.format(":!bun --watch run '%s'", vim.api.nvim_buf_get_name(buf))
        prompt_run(cmd, cmd, true)
      end
    })
  end

  return actions
end
