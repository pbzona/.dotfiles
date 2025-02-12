require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- Highlight the cursor line
o.cursorlineopt ='both'

-- Line numbers
o.number = true
o.relativenumber = true

-- Enable mouse mode
o.mouse = "a"

-- Allow access to system clipboard
o.clipboard = "unnamed,unnamedplus"

-- Always keep 8 lines above/below cursor unless at start/end of file
o.scrolloff = 8

-- Place a column line
o.colorcolumn = "80"

-- Always show the sign column
o.signcolumn = "yes"
