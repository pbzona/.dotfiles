return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "biome",
        "gopls",
        "shfmt",
        "stylua",
      },
    },
  },
}
