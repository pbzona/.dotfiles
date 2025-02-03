return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "go",
        "gomod",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    lazy = false,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    --@type snacks.Config
    opts = {
      dashboard = { example = "compact_files" },
      notifier = {
        enabled = true,
        timout = 2000,
      },
      words = {
        enabled = true,
      },
    },
  },
}
