return {
  name = "godot-signals",
  dir = vim.fn.stdpath("config") .. "/lua/custom/home_brew/godot_signals",
  lazy = false,
  config = function()
    require('custom.home_brew.godot_signals').setup({
      debug = false,
      window = {
        width = 100,
        height = 35,
        border = 'rounded',
        position = 'bottom'
      },
      keymaps = {
        toggle = '<leader>gs',
        refresh = '<leader>gr',
      }
    })
  end
}
