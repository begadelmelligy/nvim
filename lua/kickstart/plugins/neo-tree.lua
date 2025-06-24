-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  event = 'UIEnter',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
opts = {
  filesystem = {
    use_libuv_file_watcher = true,
    follow_current_file = {
      enabled = false,
    },
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = true,
      never_show = { ".git", "node_modules", ".cache" },
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
},
}
