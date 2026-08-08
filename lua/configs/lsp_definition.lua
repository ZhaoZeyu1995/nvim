-- Go-to-definition that always stays in the current window.
--
-- `vim.lsp.buf.definition` already lands on the exact line and column of the
-- definition. We pass an `on_list` handler purely to centre the result on
-- screen and to keep the multi-candidate case in the quickfix list.
--
-- A definition in another file is opened as an ordinary buffer in this
-- window, so it shows up in NvChad's tabufline and closes with <leader>x.

local M = {}

-- Move the cursor, recording the jump so <C-o> comes back here, and centre
-- the definition on screen.
local function jump_to(item)
  vim.cmd "normal! m'"
  local line_count = vim.api.nvim_buf_line_count(0)
  vim.api.nvim_win_set_cursor(0, { math.min(item.lnum, line_count), math.max(item.col - 1, 0) })
  vim.cmd "normal! zz"
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

  if target ~= current then
    -- Push the origin onto the jumplist before switching buffers, so <C-o>
    -- still returns to the call site.
    vim.cmd "normal! m'"
    vim.cmd("edit " .. vim.fn.fnameescape(target))
  end

  jump_to(item)
end

M.goto_definition = function()
  vim.lsp.buf.definition { on_list = handle_list }
end

return M
