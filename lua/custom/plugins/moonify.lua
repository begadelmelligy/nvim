return {
    "bluz71/vim-moonfly-colors",
    version = "v2", -- Make sure to use version 2 for Neovim
    lazy = false,
    priority = 1000,
    name = "moonfly",
    config = function()
        vim.cmd("colorscheme moonfly")

        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
}
