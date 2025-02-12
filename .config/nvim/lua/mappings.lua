require "nvchad.mappings"

-- Be explicit for easier readability
-- local map = vim.keymap.set

local opts = { noremap = true, silent = true }

-- Enter command mode
vim.keymap.set("n", ";", ":", opts) 

-- Quick escape from insert mode
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("i", "jk", "<ESC>")

-- Save
vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Toggle render-markdown
vim.keymap.set("n", "<leader>kd", function()
  require("render-markdown").buf_toggle()
end, opts)

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dp')
vim.keymap.set("v", "P", '"_dP')

-- Copy everything between { and } including the brackets
-- p puts text after the cursor,
-- P puts text before the cursor.
vim.keymap.set("n", "YY", "va{Vy", opts)

-- Navigate buffers
vim.keymap.set("n", "<Right>", ":bnext<CR>", opts)
vim.keymap.set("n", "<Left>", ":bprevious<CR>", opts)

-- Panes resizing
vim.keymap.set("n", "+", ":vertical resize +5<CR>")
vim.keymap.set("n", "_", ":vertical resize -5<CR>")
vim.keymap.set("n", "=", ":resize +5<CR>")
vim.keymap.set("n", "-", ":resize -5<CR>")

-- Split line with X
vim.keymap.set("n", "X", ":keeppatterns substitute/\\s*\\%#\\s*/\\r/e <bar> normal! ==^<cr>", { silent = true })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", opts)

-- Show history
vim.keymap.set("n", "<leader>hh", ":lua Snacks.picker.notifications()<CR>", opts)
