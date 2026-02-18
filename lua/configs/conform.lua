local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    css = { "prettier" },
    html = { "prettier" },
    sh = { "shfmt" },
  },

  format_on_save = false,
}

return options
