# Repository Guidelines

## Project Structure & Module Organization
This repository is a personal Neovim config built on NvChad (loaded as a plugin, not vendored).

- `init.lua`: entrypoint that bootstraps `lazy.nvim` and loads user modules.
- `lua/plugins/init.lua`: single source of truth for plugin specs (returns one table).
- `lua/configs/`: plugin-specific config modules (for example `conform.lua`, `lspconfig.lua`).
- `lua/options.lua`, `lua/mappings.lua`, `lua/autocmds.lua`: overrides/extensions to NvChad defaults.
- `lua/chadrc.lua`: UI/theme config matching NvChad’s expected schema.
- `lazy-lock.json`: pinned plugin versions for reproducible installs.

## Build, Test, and Development Commands
- `nvim --headless "+Lazy! sync" +qa`: install/update plugins from lock/spec.
- `nvim --headless "+checkhealth" +qa`: run Neovim health checks.
- `stylua --check lua/`: formatting check for Lua files.
- `stylua lua/`: apply Lua formatting.

Run commands from the repository root (`~/.config/nvim`).

## Coding Style & Naming Conventions
- Follow `.stylua.toml`: 2-space indentation, 120-column width, Unix line endings, double-quote preference.
- Keep module names lowercase and descriptive (`lua/configs/<plugin>.lua`).
- Put non-trivial plugin setup in `lua/configs/` and reference it from `lua/plugins/init.lua` via `require "configs.<name>"`.
- Prefer modern Neovim 0.11 APIs (for example `vim.lsp.enable()`).

## Testing Guidelines
There is no automated unit test suite in this repo. Validate changes with:

1. `stylua --check lua/`
2. `nvim --headless "+Lazy! sync" +qa`
3. Manual smoke test in Neovim (startup, keymaps, LSP attach, formatting on save).

For regressions, test the exact edited area (for example mappings, formatter behavior, or plugin load paths).

## Commit & Pull Request Guidelines
- Use short, imperative commit subjects (history follows patterns like `Add ...`, `Fix ...`, `Update ...`, `Configure ...`).
- Keep each commit focused on one concern (plugin add, mapping change, formatter fix).
- PRs should include:
  - what changed and why,
  - any user-facing keymap/behavior changes,
  - verification steps run (commands + manual checks),
  - linked issue (if applicable).
