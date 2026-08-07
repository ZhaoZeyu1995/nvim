require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- git blame (gitsigns): press the same key again to jump inside the float
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "git blame current line" })

map("n", "<leader>gB", function()
  require("gitsigns").blame_line { full = true }
end, { desc = "git blame current line (full commit + diff)" })

map("n", "<leader>gf", "<cmd>Gitsigns blame<cr>", { desc = "git blame full file" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
