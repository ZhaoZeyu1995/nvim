-- Install the language servers and formatters this config depends on.
--
-- lazy.nvim reproduces the *plugins* from lazy-lock.json, but Mason packages
-- live outside that: without this, a fresh clone on another machine has no
-- pyright/clangd and `gd` silently does nothing in Python and C++ buffers.
--
-- NvChad prepends Mason's bin directory to $PATH (nvchad/options.lua), so
-- anything installed here is found by the LSP and formatter commands.

local M = {}

-- Keep in sync with the servers in configs/lspconfig.lua and the formatters
-- in configs/conform.lua.
M.packages = {
  -- language servers
  "clangd",
  "pyright",
  "lua-language-server",
  "html-lsp",
  "css-lsp",
  -- formatters (see configs/conform.lua)
  "stylua",
  "black",
  "isort",
  "prettier",
  "shfmt",
}

-- Shared across calls so the blocking :MasonEnsure path waits on an in-flight
-- run rather than kicking off a second one.
local state = nil

-- An interrupted install (Ctrl-C, or Neovim exiting mid-download) removes the
-- package directory but leaves its symlink behind in mason/bin. Mason then
-- refuses to reinstall -- '"<path>" is already linked.' -- so the package
-- stays broken forever, silently. A symlink whose target is gone is useless
-- by definition, so clear those out before installing.
local function prune_dangling_links()
  local root = vim.fn.stdpath "data" .. "/mason"
  local pruned = {}

  -- Mason links into bin/ and also share/ (LSP setting schemas), so both have
  -- to be swept; share/ is nested, hence the depth.
  for _, sub in ipairs { "bin", "share" } do
    local base = root .. "/" .. sub
    if vim.uv.fs_stat(base) then
      for name, type in vim.fs.dir(base, { depth = 4 }) do
        local path = base .. "/" .. name
        -- fs_stat follows symlinks (nil => broken target); fs_lstat does not
        -- (non-nil => the link itself is still there).
        if type == "link" and not vim.uv.fs_stat(path) then
          vim.uv.fs_unlink(path)
          table.insert(pruned, sub .. "/" .. name)
        end
      end
    end
  end

  if #pruned > 0 then
    vim.schedule(function()
      vim.notify("[mason] cleared broken links: " .. table.concat(pruned, ", "), vim.log.levels.WARN)
    end)
  end
end

local function start()
  state = { done = false, pending = 0, failed = {} }

  prune_dangling_links()

  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    state.done = true
    return
  end

  registry.refresh(function()
    local missing = {}

    for _, name in ipairs(M.packages) do
      local found, pkg = pcall(registry.get_package, name)
      if found and not pkg:is_installed() then
        table.insert(missing, pkg)
      end
    end

    if #missing == 0 then
      state.done = true
      return
    end

    state.pending = #missing

    vim.schedule(function()
      vim.notify(("[mason] installing %d missing package(s); :Mason to watch"):format(#missing), vim.log.levels.INFO)
    end)

    for _, pkg in ipairs(missing) do
      pkg:install(nil, function(success)
        if not success then
          table.insert(state.failed, pkg.name)
        end
        state.pending = state.pending - 1
        if state.pending == 0 then
          state.done = true
        end
      end)
    end
  end)
end

---@param opts? { blocking?: boolean, timeout?: integer }
---Install anything missing. Already-installed packages are left alone -- this
---never upgrades behind your back; use :Mason for that.
---
---`blocking` waits for the installs to finish, which headless bootstrap needs:
---without it Neovim exits mid-download and Mason aborts the installs.
function M.install_missing(opts)
  opts = opts or {}

  if not state then
    start()
  end

  if not opts.blocking then
    return
  end

  -- Downloading clangd on a cold machine is slow; be generous.
  if not vim.wait(opts.timeout or 600000, function()
    return state.done
  end, 500) then
    vim.notify("[mason] timed out waiting for installs", vim.log.levels.WARN)
    return
  end

  if #state.failed > 0 then
    vim.notify("[mason] failed to install: " .. table.concat(state.failed, ", "), vim.log.levels.ERROR)
  end
end

return M
