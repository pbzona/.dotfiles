return {
  {
    "echasnovski/mini.surround",
    version = "*",
    -- Cannot lazy load because of some early setup requirements
    lazy = false,
  },
  config = function()
    require("mini.surround").setup()
  end,
}
