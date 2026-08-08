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

  -- NvChad loads Mason only on :Mason*, which means a fresh clone never
  -- installs the servers/formatters this config expects. Load it on VeryLazy
  -- instead and fetch anything missing. See configs/mason_ensure.lua.
  {
    "mason-org/mason.nvim",
    event = "VeryLazy",
    opts = function()
      return require "nvchad.configs.mason"
    end,
    config = function(_, opts)
      require("mason").setup(opts)
      require("configs.mason_ensure").install_missing()
    end,
  },

  -- Avante driven by Claude Code on your Pro/Max subscription (no API key).
  -- It talks ACP to the Zed bridge, which proxies to the Claude Code agent
  -- authenticated via the local `claude` login -- so it uses whichever account
  -- this machine is signed into.
  --
  -- The bridge is launched with `npx`, so a fresh machine needs no manual npm
  -- step: on first use npx downloads and caches it automatically (requires
  -- Node.js/npm on PATH). For a faster startup you may optionally pre-install
  -- it once: `npm install -g @zed-industries/claude-code-acp` and change the
  -- command below to "claude-code-acp" with empty args.
  {
    "yetone/avante.nvim",
    build = vim.fn.has "win32" ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      instructions_file = "avante.md",
      provider = "claude-code",
      acp_providers = {
        ["claude-code"] = {
          command = "npx",
          args = { "-y", "@zed-industries/claude-code-acp" },
          env = {
            NODE_NO_WARNINGS = "1",
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "stevearc/dressing.nvim", -- for input provider dressing
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
      {
        -- Nicer in-buffer Markdown rendering; also renders Avante's own
        -- response buffers. Pulled in here as an Avante dependency.
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "markdown", "Avante" },
        config = function()
          -- Patch nvim-treesitter (legacy master) query directives for Neovim
          -- 0.12+ before any markdown is parsed. See configs/ts_predicates_fix.
          require "configs.ts_predicates_fix"
          require("render-markdown").setup { file_types = { "markdown", "Avante" } }
        end,
      },
    },
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
        "bash",
      },
    },
  },

  -- Glow setup for markdown preview
  { "ellisonleao/glow.nvim", config = true, cmd = "Glow" },
}
