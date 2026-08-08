# Neovim config (NvChad-based)

Personal Neovim configuration, kept in git so it can be reproduced on any
machine. It is built on top of [NvChad](https://github.com/NvChad/NvChad)
(imported as a plugin) and managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Setting up a new machine, from scratch

Run these steps in order. Every block is copy-pasteable as-is. Pick **one** of
the platform blocks in step 1, then continue with the shared steps.

### What is required and what is not

git carries the config and lazy.nvim installs the plugins, but these system
tools have to exist first. **Only the first group is required** — everything in
the second is a feature you can live without, listed with what you lose.

**Required.** Without these something is broken, usually silently.

| Tool | Needed for | If missing |
| --- | --- | --- |
| **Neovim ≥ 0.11** (tested 0.12) | the editor | config errors out — it uses `vim.lsp.config` |
| **git** | cloning the config and every plugin | nothing installs |
| **curl**, **tar**, **gzip**, **unzip**, **bash** | how Mason downloads and unpacks packages | language servers fail to install |
| **C compiler + make** | compiling treesitter parsers; Avante's build step | no syntax highlighting for python/cpp/etc. |
| **Node.js + npm** | Mason's `pyright`, `prettier`, `html-lsp`, `css-lsp`; Avante's ACP bridge | no Python LSP, so `gd` is silent in `.py` |
| **python3 + venv + pip** | Mason installs `black` and `isort` from PyPI into a venv | Python formatting fails |

On Debian/Ubuntu, `venv` and `pip` are **separate packages** from `python3` —
this is the easiest one to miss.

**Optional.** Each buys one feature; skipping it breaks nothing else.

| Tool | Buys you | Skip it if |
| --- | --- | --- |
| **ripgrep** | Telescope live-grep (`<leader>fw`) | you only use file search, which works without it |
| A **Nerd Font** | the UI icons | you can tolerate boxes where icons should be — nothing functional breaks |
| **`claude` CLI** | Avante AI chat/edit | you do not use Avante |
| **cmake** | generating `compile_commands.json` in *your own* C++ projects | your projects generate it another way — nothing in this config needs cmake to install |
| **pngpaste** / **xclip** / **wl-clipboard** | pasting images into Avante via img-clip | you do not paste images |

Language servers and formatters are **not** in either table — Mason installs
those for you in step 4.

### Step 1 — system packages

Pick your platform. Each block is split into required and optional so you can
paste just the first line if you want a minimal install.

#### macOS

Homebrew from [brew.sh](https://brew.sh) if you do not have it:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Required (`curl`, `tar`, `gzip`, `unzip`, `bash` and `python3` already ship
with macOS; `xcode-select` provides git, clang and make):

```bash
xcode-select --install     # skip if already installed
brew install neovim node
```

Optional:

```bash
brew install ripgrep cmake
brew install --cask font-jetbrains-mono-nerd-font
```

#### Linux — Debian / Ubuntu

Required. The apt `neovim` and `nodejs` packages are usually too old, so those
two come from upstream below:

```bash
sudo apt update
sudo apt install -y build-essential git curl tar gzip unzip \
                    python3 python3-venv python3-pip
```

Node.js 22 — required, for `pyright`, `prettier` and Avante:

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

Neovim stable — required. Installs into `~/.local`, picking the right
architecture automatically:

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

Optional:

```bash
sudo apt install -y ripgrep cmake xclip
```

#### Linux — Fedora / RHEL

Required:

```bash
sudo dnf install -y @development-tools git curl tar gzip unzip \
                    python3 python3-pip nodejs
```

Then install Neovim with the same three blocks as Debian/Ubuntu above.

Optional:

```bash
sudo dnf install -y ripgrep cmake xclip
```

### Step 2 — check the required tools landed

This checks the required set only, and prints a MISSING line for anything that
is not there:

```bash
for c in nvim git curl tar gzip unzip bash cc make node npm python3; do
  command -v "$c" >/dev/null || echo "MISSING: $c"
done
python3 -m venv --help >/dev/null 2>&1 || echo "MISSING: python3 venv module"
nvim --version | head -1
```

`nvim --version` must report **v0.11.0 or newer** — if it says 0.10 or older,
stop and fix that first, as the config uses `vim.lsp.config`.

Optional tools are deliberately not checked here; see the table above for what
each one buys.

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

### Step 6 — optional per-machine extras

At this point the config is fully working. Everything below is optional, is
tied to one feature, and cannot be carried by git.

**Nerd Font** — for the UI icons. Installed by the Homebrew cask in step 1 on
macOS; on Linux install one manually. Either way you must then **select it in
your terminal's settings**, or icons render as boxes. When working on a remote
server the font belongs to your *local* terminal, not the server. Nothing
functional depends on this.

**`claude` CLI** — only if you want Avante; see the next section.

**Clipboard helper** — only for pasting images into Avante via img-clip:
`pngpaste` on macOS, `xclip` or `wl-clipboard` on Linux.

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
