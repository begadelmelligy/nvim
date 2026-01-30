return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,    -- 🔥 REQUIRED
  priority = 1000, -- load early
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({ -- Changed from nvim-treesitter.configs
      ensure_installed = {
        "c",
        "lua",
        "python",
        "vim",
        "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
