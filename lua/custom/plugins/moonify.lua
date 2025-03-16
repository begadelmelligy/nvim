return {
  {
    "bluz71/vim-moonfly-colors",
    version = "v2",  -- Make sure to use version 2 for Neovim
    lazy = false,
    priority = 1000,
    config = function()
      -- Set options before loading the colorscheme
      vim.g.moonflyCursorColor = true
      vim.g.moonflyItalics = false
      -- Make sure the plugin is fully loaded before setting colorscheme
      vim.cmd([[colorscheme moonfly]])
    end,
  },
}
