return {
{
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui", -- UI for DAP
        "theHamsta/nvim-dap-virtual-text", -- Inline virtual text for debugging
    },
    config = function()
        require("nvim-dap-virtual-text").setup()
    end
}
}


