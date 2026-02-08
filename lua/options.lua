require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!

-- Treesitter-based code folding, expanded by default
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99

-- Set up spell checking to British English
o.spell = true
o.spelllang = "en_gb"

-- Set no line wrap
o.wrap = false

-- Indentation
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
