return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "biome",
        "elixirls",
        "gopls",
        "shfmt",
        "stylua",
      },
    },
  },
}
