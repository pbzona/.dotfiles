
return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    --@type snacks.Config
    opts = {
      dashboard = { example = "compact_files" },
      notifier = {
        enabled = true,
        timeout = 2000,
      },
      words = {
        enabled = true,
      },
      picker = {}
    },
  }
