return {
  "neovim/nvim-lspconfig",
  ft = { "gd", "gdscript", "gdshader" },
  opts = function(_, opts)
    local lspconfig = require("lspconfig")

    -- Add Godot LSP configuration
    lspconfig.gdscript.setup({
      name = "godot",
      cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),
      filetypes = { "gd", "gdscript", "gdshader" },
      root_dir = lspconfig.util.root_pattern("project.godot"),
    })
  end,
}
}
