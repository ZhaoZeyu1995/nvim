# Copilot Instructions

## Architecture

This is a Neovim configuration built on **NvChad v2.5**, targeting **Neovim 0.11+**. NvChad is loaded as a lazy.nvim plugin (not forked), so its modules are imported via `require "nvchad.*"`.

- `init.lua` — Entry point: bootstraps lazy.nvim, loads NvChad as a plugin, then loads user config
- `lua/plugins/init.lua` — All user plugin specs (single file, returns a table)
- `lua/configs/` — Plugin-specific configuration modules, referenced by plugin specs via `require "configs.<name>"`
- `lua/options.lua` — Vim options (extends `nvchad.options`)
- `lua/mappings.lua` — Keymaps (extends `nvchad.mappings`)
- `lua/chadrc.lua` — NvChad UI/theme config (structure must match `nvconfig.lua`)
- `lua/autocmds.lua` — Autocommands (extends `nvchad.autocmds`)

Key plugins: `copilot.lua` (GitHub Copilot), `avante.nvim` (AI chat, using Copilot provider), `conform.nvim` (formatting), `nvim-lspconfig`, `nvim-treesitter`.

## Conventions

- **Lua style**: 2-space indentation, Unix line endings, 120 column width, double quotes preferred, no call parentheses (see `.stylua.toml`)
- **Exception**: `chadrc.lua` uses 4-space indentation to match the user's general indentation preference
- **Plugin specs**: All user plugins go in `lua/plugins/init.lua` as a single returned table — do not create separate plugin files
- **Config separation**: Non-trivial plugin configs go in `lua/configs/<plugin>.lua` and are loaded via `require "configs.<name>"` in the plugin spec
- **LSP servers**: Use `vim.lsp.enable()` (Neovim 0.11 native API), not the older `lspconfig[server].setup()` pattern
- **Folding**: Uses native `vim.treesitter.foldexpr()`, not the deprecated `nvim-treesitter` module API
- **Formatting**: conform.nvim with format-on-save (`BufWritePre`); use `lsp_format = "fallback"` (not the deprecated `lsp_fallback`)

## Lint / Format

```sh
stylua --check lua/    # check formatting
stylua lua/            # apply formatting
```
