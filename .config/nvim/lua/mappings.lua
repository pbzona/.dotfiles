require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("v", "jk", "<ESC>")

-- Make it wait so that mini.surround combos work
-- map({ "n", "v" }, "s", "<Nop>", { desc = "Do nothing" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
