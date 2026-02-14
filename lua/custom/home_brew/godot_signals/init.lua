local M = {}
local parser = require('custom.home_brew.godot_signals.parser')
local ui = require('custom.home_brew.godot_signals.ui')

-- Plugin state
M.state = {
  signals = {},
  connections = {},
  buf = nil,
  win = nil,
  project_root = nil
}

-- Configuration
M.config = {
  debug = false, -- Enable to see parsing details
  window = {
    width = 60,
    height = 20,
    border = 'rounded',
    position = 'right' -- 'right', 'left', 'bottom', 'float'
  },
  keymaps = {
    toggle = '<leader>gs',
    refresh = '<leader>gr',
    goto_definition = '<CR>',
    goto_connection = 'gc',
    close = 'q',
    expand_collapse = '<Tab>',
  },
  icons = {
    signal = '📡',
    connection = '🔗',
    script = '📄',
    scene = '🎬',
    expanded = '▼',
    collapsed = '▶',
  },
  search_patterns = {
    signal_definition = 'signal%s+(%w+)',
    signal_emit = '%.emit_signal%s*%(%s*["\']([%w_]+)["\']',
    signal_connect = '%.connect%s*%(%s*["\']([%w_]+)["\']%s*,%s*([^,)]+)%s*,%s*["\']([%w_]+)["\']',
  }
}

-- Find project root (looks for project.godot)
function M.find_project_root()
  local cwd = vim.fn.getcwd()
  local path = vim.fn.findfile('project.godot', cwd .. ';')
  if path ~= '' then
    return vim.fn.fnamemodify(path, ':h')
  end
  return cwd
end

-- Scan project for signals and connections
function M.find_signals()
  M.state.project_root = M.find_project_root()

  -- Find all .gd and .tscn files
  local gd_files = vim.fn.globpath(M.state.project_root, '**/*.gd', false, true)
  local tscn_files = vim.fn.globpath(M.state.project_root, '**/*.tscn', false, true)

  -- Parse files
  M.state.signals = {}
  M.state.connections = {}

  for _, file in ipairs(gd_files) do
    parser.parse_gd_file(file, M.state.signals, M.state.connections, M.config)
  end

  for _, file in ipairs(tscn_files) do
    parser.parse_tscn_file(file, M.state.connections, M.config)
  end

  -- Link connections to signals
  parser.link_connections(M.state.signals, M.state.connections)

  -- Show in UI
  ui.show(M.state, M.config)

  vim.notify('Found ' .. #vim.tbl_keys(M.state.signals) .. ' signals', vim.log.levels.INFO)
end

-- Toggle window
function M.toggle_window()
  if M.state.win and vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_close(M.state.win, true)
    M.state.win = nil
    M.state.buf = nil
  else
    if vim.tbl_isempty(M.state.signals) then
      M.find_signals()
    else
      ui.show(M.state, M.config)
    end
  end
end

-- Refresh data
function M.refresh()
  M.find_signals()
end

-- Setup function for configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Set up keymaps if configured
  if M.config.keymaps.toggle then
    vim.keymap.set('n', M.config.keymaps.toggle, function()
      M.toggle_window()
    end, { desc = 'Toggle Godot signals window' })
  end

  if M.config.keymaps.refresh then
    vim.keymap.set('n', M.config.keymaps.refresh, function()
      M.refresh()
    end, { desc = 'Refresh Godot signals' })
  end
end

return M
