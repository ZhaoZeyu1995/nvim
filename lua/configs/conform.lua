local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    css = { "prettier" },
    html = { "prettier" },
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 3000,
    lsp_fallback = true,
  },
}

return options
