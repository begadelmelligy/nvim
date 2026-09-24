-- lua/plugins/rose-pine.lua
return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000,
  config = function()
    require("rose-pine").setup({
      styles = {
        transparency = true,
      },

      highlight_groups = {
        ["@variable"] = { fg = "iris" },
        ["@variable.builtin"] = { fg = "love", italic = true },
        ["@variable.member"] = { fg = "foam" },
        ["@variable.parameter"] = { fg = "iris" },
        ["@property"] = { fg = "foam" },
        ["@function"] = { fg = "rose" },
        ["@function.call"] = { fg = "rose" },
      },
    })

    vim.cmd.colorscheme("rose-pine")
  end,
}
