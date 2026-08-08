# Neovim config (NvChad-based)

Personal Neovim configuration, kept in git so it can be reproduced on any
machine. It is built on top of [NvChad](https://github.com/NvChad/NvChad)
(imported as a plugin) and managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Setup on a new machine

```bash
git clone https://github.com/ZhaoZeyu1995/nvim.git ~/.config/nvim
nvim   # first launch bootstraps lazy.nvim and installs everything
```

(Use `git@github.com:ZhaoZeyu1995/nvim.git` instead if you want to push from
this machine and have an SSH key set up on it.)

On first launch, **automatically** (no manual steps):

- `lazy.nvim` is cloned and all plugins are installed to the exact commits
  pinned in `lazy-lock.json` (reproducible).
- Avante's native helpers are compiled via its `make` build step.
- Treesitter parsers listed in `lua/plugins/init.lua` are installed.
- The Claude Code ACP bridge is fetched on first use of Avante via `npx`
  (cached afterwards) — no global npm install required.
- Mason installs the language servers and formatters listed in
  `lua/configs/mason_ensure.lua` (clangd, pyright, lua-language-server,
  html-lsp, css-lsp, stylua, black, isort, prettier, shfmt). Plugins come from
  `lazy-lock.json`, but Mason packages are outside it — without this step `gd`
  would silently do nothing in Python and C++ buffers on a fresh machine.

Let the initial `:Lazy` sync finish, then restart Neovim once.

### Headless / remote servers

The Mason step above runs on the `VeryLazy` event, which never fires without a
UI. To provision a server without opening the editor, run the bootstrap
explicitly — it blocks until every package is installed, so it is safe in a
script:

```bash
git clone https://github.com/ZhaoZeyu1995/nvim.git ~/.config/nvim
nvim --headless "+Lazy! sync" +qa     # plugins
nvim --headless "+MasonEnsure" +qa    # language servers and formatters
```

`:MasonEnsure` only installs what is *missing*; it never upgrades behind your
back (use `:Mason` for that). It also clears broken symlinks left behind by an
interrupted install, which otherwise make Mason refuse to reinstall a package
(`"…/mason/bin/clangd" is already linked.`) and leave it silently broken.

## Prerequisites (these are NOT installed by git)

git can carry the config, and lazy.nvim installs the *plugins*, but the
following system tools must exist on the machine first:

| Tool | Why | Install (macOS) |
| --- | --- | --- |
| **Neovim ≥ 0.11** (tested on 0.12) | the editor | `brew install neovim` |
| **git** | clone repo + plugin installs | `xcode-select --install` |
| **C compiler + make** | build treesitter parsers; run Avante's build | `xcode-select --install` |
| **curl + tar** | Avante downloads its prebuilt native libs | preinstalled on macOS/Linux |
| **Node.js + npm** | runs the Claude Code ACP bridge via `npx`; also Mason's `pyright` and `prettier` | `brew install node` |
| **`claude` CLI, logged in** | Avante uses your Claude subscription | see below |
| **ripgrep** | Telescope live-grep | `brew install ripgrep` |
| A **Nerd Font** | icons in the UI | e.g. `brew install --cask font-jetbrains-mono-nerd-font` |
| **glow** (optional) | `:Glow` markdown preview | `brew install glow` |

On Linux, use the equivalent packages (`build-essential`, `nodejs`, `npm`,
`ripgrep`, etc.).

Both macOS and Linux (x86_64 and arm64/aarch64) are supported: Avante's build
auto-downloads the prebuilt native library for the detected OS and architecture,
so no compiler is needed for it in the normal path. Only if the release lookup
fails does it fall back to building from source, which then requires Rust
(`cargo`). Image pasting via img-clip is optional and, if used, needs a
clipboard helper per OS (`pngpaste` on macOS; `xclip`/`wl-clipboard` on Linux).

## Claude Code in Avante (uses your subscription, not an API key)

Avante is configured to talk to Claude Code over ACP through the local `claude`
CLI, so it uses **whatever account this machine is signed into** — no API key,
nothing but your local login leaves the machine. Per machine:

1. Install the Claude Code CLI and sign in with your subscription:
   ```bash
   claude        # then run /login and follow the browser flow
   ```
2. That's it — the ACP bridge (`@zed-industries/claude-code-acp`) is pulled by
   `npx` on first use. To avoid the first-run download latency you may
   optionally pre-install it: `npm install -g @zed-industries/claude-code-acp`.

Usage: `:AvanteAsk` (or `<leader>aa`) to chat; select code + `<leader>ae` to edit.

## Language support

`gd` jumps to the definition under the cursor. If it is in the current file the
cursor moves in place; otherwise the file opens as an ordinary buffer in the
same window, so it appears in the tabufline and closes with `<leader>x`. Use
`<C-o>` to jump back. Several candidates (C++ overloads, header/source pairs)
go to the quickfix list.

For **C++**, clangd needs a `compile_commands.json` to resolve `#include`s.
Without one it guesses compiler flags and cross-file jumps into project headers
may fail. Generate it with CMake:

```bash
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .
```

For **Python**, pyright resolves imports against the interpreter it finds on
`PATH`. Inside a virtualenv or conda env, launch `nvim` with that env active,
or add a `pyrightconfig.json` with `venvPath`/`venv` at the project root.

## Notes

- `lua/configs/ts_predicates_fix.lua` patches nvim-treesitter's legacy `master`
  branch query directives for Neovim 0.12 (fixes Markdown rendering crashes).
- This repo is meant to be used as config by NvChad users; the main NvChad repo
  is imported as a plugin.

# Credits

- [NvChad](https://github.com/NvChad/NvChad)
- [LazyVim starter](https://github.com/LazyVim/starter) — inspired NvChad's starter.
