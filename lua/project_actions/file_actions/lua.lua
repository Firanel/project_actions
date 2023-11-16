local lua_actions = {
  {
    name = "Lua: run",
    run = function(buf)
      vim.cmd(string.format(":!lua '%s'", vim.api.nvim_buf_get_name(buf)))
    end,
  },
}

return function() return lua_actions end
