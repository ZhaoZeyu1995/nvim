require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

-- Set the foldmethod to expr
o.foldmethod = "expr" -- foldmethod=expr
o.foldexpr = "nvim_treesitter#foldexpr()" -- foldexpr=nvim_treesitter#foldexpr()

-- Set up spell checking to British English
o.spell = true
o.spelllang = "en_gb"

-- Set no line wrap
o.wrap = false

-- Indentation
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
