require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })

map("i", "jk", "<ESC>")
-- Disabling for visual mode because it messes with v-line selection
-- map("v", "jk", "<ESC>")

-- Save
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Toggle render-markdown
map("n", "<leader>rm", function()
  require("render-markdown").buf_toggle()
end, { desc = "Toggle render-markdown for current buffer" })

-- Searching
map("n", "<leader>fo", require("telescope.builtin").oldfiles, { desc = "[F]ind recently [O]pened files" })
map("n", "<leader>fh", require("telescope.builtin").help_tags, { desc = "[F]ind [H]elp" })
