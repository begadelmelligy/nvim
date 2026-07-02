-- This is a formatter, you have to download the different formaters and this plugin just runs them sequentially
return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        xml = { "xmlformatter" },
      },
    })
  end,
}
