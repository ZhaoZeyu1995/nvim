-- Compatibility fix for nvim-treesitter's legacy `master` branch on Neovim
-- 0.12+.
--
-- Neovim 0.11+/0.12 changed query directive handlers so that `match[capture_id]`
-- is now a LIST of nodes (`TSNode[]`) instead of a single `TSNode`. The frozen
-- `master` branch of nvim-treesitter still does `local node = match[capture_id]`
-- and then calls node methods on it, which crashes with
--   "attempt to call method 'range' (a nil value)"
-- whenever such a directive runs -- e.g. rendering a Markdown code block, which
-- uses `set-lang-from-info-string!` and `downcase!`.
--
-- We re-register the markdown-relevant directives with `force = true`, pulling
-- the actual node out of the list. `node_of` accepts both the new (list) and
-- old (single node) shapes so this stays correct on either Neovim version.

-- Make sure nvim-treesitter has registered its (broken) directives first, so
-- our `force = true` versions override them rather than the reverse.
pcall(require, "nvim-treesitter.query_predicates")

local query = require "vim.treesitter.query"

---Return a single node from a match value that may be a list of nodes (Neovim
---0.12+) or a single node (older Neovim). Mirrors the legacy `all = false`
---behaviour by taking the last matched node.
---@param value TSNode|TSNode[]|nil
---@return TSNode|nil
local function node_of(value)
  if type(value) == "table" then
    return value[#value]
  end
  return value
end

-- Replicated from nvim-treesitter/query_predicates.lua (module-local data).
local html_script_type_languages = {
  ["importmap"] = "json",
  ["module"] = "javascript",
  ["application/ecmascript"] = "javascript",
  ["text/ecmascript"] = "javascript",
}

local non_filetype_match_injection_language_aliases = {
  ex = "elixir",
  pl = "perl",
  sh = "bash",
  uxn = "uxntal",
  ts = "typescript",
}

local function get_parser_from_markdown_info_string(injection_alias)
  local match = vim.filetype.match { filename = "a." .. injection_alias }
  return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
end

local opts = { force = true }

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
  local node = node_of(match[pred[2]])
  if not node then
    return
  end
  local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
  metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
end, opts)

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
  local node = node_of(match[pred[2]])
  if not node then
    return
  end
  local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
  local configured = html_script_type_languages[type_attr_value]
  if configured then
    metadata["injection.language"] = configured
  else
    local parts = vim.split(type_attr_value, "/", {})
    metadata["injection.language"] = parts[#parts]
  end
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
  local id = pred[2]
  local node = node_of(match[id])
  if not node then
    return
  end
  local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""
  if not metadata[id] then
    metadata[id] = {}
  end
  metadata[id].text = string.lower(text)
end, opts)
