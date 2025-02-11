require "nvchad.options"

local o = vim.o
local opt = vim.opt

o.cursorlineopt ='both' -- to enable cursorline!

-- Line numbers
opt.nu = true
opt.rnu = true

-- Enable mouse mode
opt.mouse = "a"

-- Allow access to system clipboard
opt.clipboard = "unnamed,unnamedplus"

-- Always keep 8 lines above/below cursor unless at start/end of file
opt.scrolloff = 8

-- Place a column line
opt.colorcolumn = "80"

-- Always show the sign column
opt.signcolumn = "yes"
