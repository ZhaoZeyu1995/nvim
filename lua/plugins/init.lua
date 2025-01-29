return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Copilot setup for autocompletion with Github Copilot
  {
    "github/copilot.vim",
    lazy = false,
  },

  -- Treesitter setup for syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "c",
        "cpp",
      },
    },
  },

  -- Glow setup for markdown preview
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
}
