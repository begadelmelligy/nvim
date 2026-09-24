return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local languages = {
      "c",
      "lua",
      "python",
      "vim",
      "vimdoc",
    }

    -- Replaces the old ensure_installed option.
    require("nvim-treesitter").install(languages)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = languages,
      callback = function(event)
        -- Replaces highlight = { enable = true }.
        pcall(vim.treesitter.start, event.buf)

        -- Replaces indent = { enable = true }.
        vim.bo[event.buf].indentexpr =
        "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
