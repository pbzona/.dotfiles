return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "html",
        "elixir",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "javascript",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      },
    },
  },
}
