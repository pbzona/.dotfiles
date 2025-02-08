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
        "markdown",
        "markdown_inline",
        "json",
        "go",
        "gomod",
        "rust",
        "sql",
      },
    },
  },
  {
    "echasnovski/mini.surround",
    version = "*",
    lazy = false,
  },
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    opts = {},
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
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
