return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' }, -- Trigger formatting on save
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true, -- Use LSP formatting as a fallback if available
    },
    formatters_by_ft = {
      lua = { 'stylua' }, -- Default for Lua
      c = { 'clang_format' }, -- Add clang-format for C files
      cpp = { 'clang_format' }, -- Add clang-format for C++ files (optional)
      -- Add other filetypes as needed
    },
  },
}
