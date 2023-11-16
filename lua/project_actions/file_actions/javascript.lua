local js_actions = {
  {
    name = "Node: run",
    run = function(buf)
      vim.cmd(string.format(":!node '%s'", vim.api.nvim_buf_get_name(buf)))
    end
  },
}

return function() return js_actions end