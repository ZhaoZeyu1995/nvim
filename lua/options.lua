require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!

-- Set the foldmethod to expr
o.foldmethod = 'expr' -- foldmethod=expr
o.foldexpr = 'nvim_treesitter#foldexpr()' -- foldexpr=nvim_treesitter#foldexpr()
