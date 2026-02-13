return {
  name = "godot-resource-browser",
  dir = vim.fn.stdpath("config") .. "/lua/custom/home_brew/godot_resource_browser",
  lazy = false,
  config = function()
    require("custom.home_brew.godot_resource_browser").setup()
  end,
}
