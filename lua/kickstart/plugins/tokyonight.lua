return {
  'folke/tokyonight.nvim',
  name = "tokyonight",

  config = function()
    vim.cmd("colorscheme tokyonight")

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    require("nvim-treesitter.config").setup({
      ensure_installed = { "python", "lua", "vim", "vimdoc" },
      hightlight = {
        enable = true,
      }

    })
  end,
}
-- vim: ts=2 sts=2 sw=2 et
