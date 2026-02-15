# Repository Guidelines

## Project Structure & Module Organization
This repository is a user config layer for NvChad, not a standalone Neovim distribution.

- `init.lua`: entrypoint; bootstraps `lazy.nvim`, loads NvChad, then local modules.
- `lua/plugins/init.lua`: plugin specs and plugin-specific setup hooks.
- `lua/configs/`: focused config modules (`lazy.lua`, `lspconfig.lua`, `conform.lua`).
- `lua/options.lua`, `lua/mappings.lua`, `lua/autocmds.lua`: user overrides on top of NvChad defaults.
- `lua/chadrc.lua`: NvChad UI/theme configuration.
- `.stylua.toml`: Lua formatting rules.

Keep new config in small single-purpose modules under `lua/configs/` and import them from plugin specs.

## Build, Test, and Development Commands
- `nvim`: launch locally with this config.
- `nvim --headless "+Lazy! sync" +qa`: install/update plugins non-interactively.
- `nvim --headless "+checkhealth" +qa`: run Neovim health checks after dependency changes.
- `stylua init.lua lua`: format all Lua files using repo rules.

If you modify formatter/LSP config, run both `checkhealth` and a real editor session to verify behavior.

## Coding Style & Naming Conventions
- Language: Lua.
- Indentation: 2 spaces (enforced by `.stylua.toml`).
- Max line width: 120.
- Prefer double quotes where Stylua resolves automatically.
- Module names: lowercase, descriptive (`configs/conform.lua`).
- Keep plugin specs declarative; move non-trivial logic into `lua/configs/*.lua`.

## Testing Guidelines
There is no formal automated test suite in this repo. Validate changes with:

1. `stylua init.lua lua`
2. `nvim --headless "+checkhealth" +qa`
3. Manual smoke test in Neovim (startup, keymaps, LSP attach, formatting on save, plugin commands such as `:Glow`).

For bug fixes, include reproducible steps in the PR description and verify the fix with a minimal filetype example.

## Commit & Pull Request Guidelines
Recent history favors short, imperative commit titles (for example: `Add shell formatter shfmt`, `Fix code folding...`).

- Use one logical change per commit.
- Subject line: imperative mood, concise, and specific.
- PRs should include: purpose, changed files/modules, validation commands run, and any before/after behavior notes.
- Link related issue(s) when applicable; include screenshots/GIFs only for UI-visible changes.
