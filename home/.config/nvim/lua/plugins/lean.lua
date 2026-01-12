return {
  {
    "Julian/lean.nvim",
    event = { "BufReadPre *.lean", "BufNewFile *.lean" },

    dependencies = {
      "nvim-lua/plenary.nvim",
    },

    ---@type lean.Config
    opts = {
      -- Enable suggested mappings (see :help lean-mappings)
      mappings = true,

      -- Abbreviation support for unicode characters
      abbreviations = {
        enable = true,
        leader = "\\",
      },

      -- Infoview support
      infoview = {
        autoopen = true,
        width = 1 / 3,
        height = 1 / 3,
      },

      -- Progress bar support
      progress_bars = {
        enable = true,
      },
    },
  },

  -- Add Lean treesitter parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "lean" })
      end
    end,
  },
}
