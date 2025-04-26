return {
{
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = function(term)
                if term.direction == "horizontal" then
                    return 10
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,
            open_mapping = [[<C-\>]], -- Change this shortcut as needed
            shade_terminals = true,
            shading_factor = 2,
            direction = "float", -- This makes it a floating terminal
            float_opts={
                    width = 80,
                    height=30,
                },
            close_on_exit = true,
            persist_mode = true, -- Keeps session open
            shell = "PowerShell", -- Change to "powershell" if using older Windows PowerShell
        })
    end
}
}
