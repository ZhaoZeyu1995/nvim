-- Go-to-definition that keeps same-file jumps in place, but sends
-- cross-file jumps to their own tab.
--
-- `vim.lsp.buf.definition` already lands on the exact line and column of the
-- definition; the only thing it does not do is choose a window. We pass an
-- `on_list` handler so we can make that choice ourselves.

local M = {}

-- Move the cursor within the current window, recording the jump so <C-o>
-- comes back here, and centre the definition on screen.
local function jump_to(item)
  vim.cmd "normal! m'"
  local line_count = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_win_set_cursor(0, { math.min(item.lnum, line_count), math.max(item.col - 1, 0) })
  vim.cmd "normal! zz"
end

-- If `path` is already visible in some tab, focus that window instead of
-- opening yet another tab for it.
local function focus_existing_window(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 then
    return false
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      vim.api.nvim_set_current_win(win)
      return true
    end
  end

  return false
end

local function handle_list(options)
  local items = options.items

  if #items == 0 then
    vim.notify("No definition found", vim.log.levels.INFO)
    return
  end

  -- Several candidates (overloads, a header/source pair, ...): let the
  -- quickfix list present them rather than guessing.
  if #items > 1 then
    vim.fn.setqflist({}, " ", options)
    vim.cmd "botright copen"
    return
  end

  local item = items[1]
  local target = vim.fn.fnamemodify(item.filename, ":p")
  local current = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")

  if target == current then
    jump_to(item)
    return
  end

  -- Push the origin onto the jumplist before we leave this window, so <C-o>
  -- still works after switching back to this tab.
  vim.cmd "normal! m'"

  if not focus_existing_window(target) then
    vim.cmd("tabedit " .. vim.fn.fnameescape(target))
  end

  jump_to(item)
end

M.goto_definition = function()
  vim.lsp.buf.definition { on_list = handle_list }
end

return M
