# Neovim config (NvChad-based)

Personal Neovim configuration, kept in git so it can be reproduced on any
machine. It is built on top of [NvChad](https://github.com/NvChad/NvChad)
(imported as a plugin) and managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Setting up a new machine, from scratch

Run these steps in order. Every block is copy-pasteable as-is. Pick **one** of
the platform blocks in step 1, then continue with the shared steps.

### Step 1 — system packages

git carries the config and lazy.nvim installs the plugins, but these system
tools have to exist first. **Neovim must be 0.11 or newer** (tested on 0.12).

#### macOS

Homebrew from [brew.sh](https://brew.sh) if you do not have it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then:

```bash
xcode-select --install                      # git, clang, make (skip if already installed)
brew install neovim node ripgrep cmake glow
brew install --cask font-jetbrains-mono-nerd-font
```

#### Linux — Debian / Ubuntu

The `neovim` and `nodejs` packages in apt are usually too old, so both come
from upstream. Everything else is from apt:

```bash
sudo apt update
sudo apt install -y build-essential git curl tar unzip ripgrep cmake
```

Node.js 22 (needed by Mason's `pyright` and `prettier`, and by Avante):

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Neovim stable, into `~/.local`, picking the right architecture automatically:

```bash
ARCH=$([ "$(uname -m)" = "aarch64" ] && echo arm64 || echo x86_64)
curl -fsSL -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${ARCH}.tar.gz"
mkdir -p ~/.local/bin && tar -xzf /tmp/nvim.tar.gz -C ~/.local
ln -sf ~/.local/nvim-linux-${ARCH}/bin/nvim ~/.local/bin/nvim
```

Put `~/.local/bin` on your `PATH` if it is not already (adjust for your shell):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

#### Linux — Fedora / RHEL

```bash
sudo dnf install -y @development-tools git curl tar unzip ripgrep cmake nodejs
```

Then install Neovim with the same three blocks as Debian/Ubuntu above.

### Step 2 — check the prerequisites landed

```bash
nvim --version | head -1     # must be v0.11.0 or newer
node --version               # v20+ recommended
git --version; rg --version | head -1; cc --version | head -1
```

If `nvim --version` reports 0.10 or older, stop and fix that first — the config
uses `vim.lsp.config`, which needs 0.11.

### Step 3 — clone the config

```bash
git clone https://github.com/ZhaoZeyu1995/nvim.git ~/.config/nvim
```

Use `git@github.com:ZhaoZeyu1995/nvim.git` instead if you want to push from
this machine and have an SSH key set up on it.

> If `~/.config/nvim` already exists, move it aside first:
> `mv ~/.config/nvim ~/.config/nvim.bak`

### Step 4 — install plugins, language servers and formatters

```bash
nvim --headless "+Lazy! sync" +qa     # plugins, pinned by lazy-lock.json
nvim --headless "+MasonEnsure" +qa    # language servers and formatters
```

Both commands block until they finish, so they are safe over SSH and in
scripts. The first takes a few minutes on a cold machine.

On a desktop you can skip them and just run `nvim` — the same work happens on
first launch. On a **headless machine you must run them**: the automatic Mason
step fires on the `VeryLazy` event, which never fires without a UI.

What gets installed:

- All plugins, at the exact commits pinned in `lazy-lock.json` (reproducible).
- Avante's native helpers, via its `make` build step.
- Treesitter parsers listed in `lua/plugins/init.lua`.
- The Mason packages listed in `lua/configs/mason_ensure.lua`: clangd, pyright,
  lua-language-server, html-lsp, css-lsp, stylua, black, isort, prettier,
  shfmt. Plugins come from `lazy-lock.json`, but Mason packages sit outside it
  — without this step `gd` silently does nothing in Python and C++ buffers.

`:MasonEnsure` only installs what is *missing*; it never upgrades behind your
back (use `:Mason` for that). It also clears broken symlinks left by an
interrupted install, which otherwise make Mason refuse to reinstall a package
(`"…/mason/bin/clangd" is already linked.`) and leave it silently broken. If a
download is interrupted, just run it again.

### Step 5 — verify

```bash
nvim --headless "+checkhealth" "+%p" +qa 2>/dev/null | grep -E "ERROR|WARNING"
```

`:checkhealth` writes its report into a buffer rather than to stdout, which is
what the `+%p` (`:%print`) is for. No output means a clean bill of health; a
stray warning about `focus-events` is harmless.

Then open a real editor session and confirm the language servers attach:

```bash
nvim ~/.config/nvim/lua/mappings.lua    # :LspInfo should show lua_ls
```

Put the cursor on a function call and press `gd`; `:Mason` lists the installed
packages.

### Step 6 — per-machine extras

These cannot be carried by git and are needed once per machine.

**Nerd Font.** Installed by the Homebrew cask above on macOS; on Linux install
one manually. Either way you must then **select it in your terminal's
settings**, or icons render as boxes. When working on a remote server, the font
belongs to your *local* terminal, not the server.

**Claude CLI**, for Avante — see the next section.

**Optional.** `glow` for `:Glow` markdown preview (`brew install glow`, or from
its GitHub releases on Linux). For image pasting via img-clip, a clipboard
helper: `pngpaste` on macOS, `xclip` or `wl-clipboard` on Linux.

Both macOS and Linux on x86_64 and arm64/aarch64 are supported: Avante's build
auto-downloads the prebuilt native library for the detected OS and
architecture, so no compiler is needed for it in the normal path. Only if that
release lookup fails does it fall back to building from source, which then
requires Rust (`cargo`).

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
