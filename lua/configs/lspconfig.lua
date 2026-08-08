require("nvchad.configs.lspconfig").defaults()

-- clangd ships with the Xcode command line tools; pyright is installed via
-- :MasonInstall pyright.
local servers = { "html", "cssls", "clangd", "pyright" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers

-- Override NvChad's buffer-local `gd`. NvChad registers its own LspAttach
-- autocmd inside defaults() above, so registering ours afterwards means ours
-- runs second and its mapping wins.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "gd", require("configs.lsp_definition").goto_definition, {
      buffer = args.buf,
      desc = "LSP Go to definition",
    })
  end,
})
