local M = {}

-- Tree state for expand/collapse
M.tree_state = {}

-- Create and show the signals window
function M.show(state, config)
  -- Create buffer if it doesn't exist
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[state.buf].bufhidden = 'wipe'
    vim.bo[state.buf].filetype = 'godot-signals'
    vim.api.nvim_buf_set_name(state.buf, 'Godot Signals')
  end

  -- Create window
  local win_config
  if config.window.position == 'float' then
    win_config = {
      relative = 'editor',
      width = config.window.width,
      height = config.window.height,
      col = (vim.o.columns - config.window.width) / 2,
      row = (vim.o.lines - config.window.height) / 2,
      border = config.window.border,
      style = 'minimal'
    }
    state.win = vim.api.nvim_open_win(state.buf, true, win_config)
  else
    -- Split window
    if config.window.position == 'right' then
      vim.cmd('botright vsplit')
    elseif config.window.position == 'left' then
      vim.cmd('topleft vsplit')
    elseif config.window.position == 'bottom' then
      vim.cmd('botright split')
    end

    state.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(state.win, state.buf)

    if config.window.position == 'right' or config.window.position == 'left' then
      vim.api.nvim_win_set_width(state.win, config.window.width)
    else
      vim.api.nvim_win_set_height(state.win, config.window.height)
    end
  end

  -- Set buffer options
  vim.bo[state.buf].modifiable = false
  vim.bo[state.buf].readonly = true
  vim.wo[state.win].wrap = false
  vim.wo[state.win].cursorline = true

  -- Set up keymaps
  M.setup_keymaps(state.buf, state, config)

  -- Render content
  M.render(state, config)
end

-- Render the tree structure
function M.render(state, config)
  vim.bo[state.buf].modifiable = true

  local lines = {}
  local line_data = {} -- Store metadata for each line

  -- Header (3 lines + 1 blank = 4 lines)
  table.insert(lines, '╔═══════════════════════════════════════╗')
  table.insert(line_data, { type = 'header' })

  table.insert(lines, '║      Godot Signals Overview           ║')
  table.insert(line_data, { type = 'header' })

  table.insert(lines, '╚═══════════════════════════════════════╝')
  table.insert(line_data, { type = 'header' })

  table.insert(lines, '')
  table.insert(line_data, { type = 'spacing' })

  -- Sort signals alphabetically
  local signal_names = vim.tbl_keys(state.signals)
  table.sort(signal_names)

  -- Build tree
  for _, signal_name in ipairs(signal_names) do
    local signal = state.signals[signal_name]
    local is_expanded = M.tree_state[signal_name] ~= false -- Default to expanded

    -- Signal header
    local icon = is_expanded and config.icons.expanded or config.icons.collapsed
    local builtin_marker = signal.is_builtin and ' [built-in]' or ''
    local line = string.format('%s %s %s%s', icon, config.icons.signal, signal_name, builtin_marker)
    table.insert(lines, line)
    table.insert(line_data, {
      type = 'signal',
      signal_name = signal_name,
      data = signal
    })

    if is_expanded then
      -- Definitions
      if #signal.defined_in > 0 then
        table.insert(lines, '  │ Defined in:')
        table.insert(line_data, { type = 'label' })

        for _, def in ipairs(signal.defined_in) do
          local def_line = string.format('  │  └─ %s %s:%d', config.icons.script, def.file, def.line)
          table.insert(lines, def_line)
          table.insert(line_data, {
            type = 'definition',
            file = def.file,
            line = def.line
          })
        end
      end

      -- Emissions
      if #signal.emissions > 0 then
        table.insert(lines, '  │ Emitted in:')
        table.insert(line_data, { type = 'label' })

        for _, emission in ipairs(signal.emissions) do
          local emit_line = string.format('  │  └─ %s:%d', emission.file, emission.line)
          table.insert(lines, emit_line)
          table.insert(line_data, {
            type = 'emission',
            file = emission.file,
            line = emission.line
          })
        end
      end

      -- Connections
      if #signal.connections > 0 then
        table.insert(lines, '  │ Connected to:')
        table.insert(line_data, { type = 'label' })

        for _, conn in ipairs(signal.connections) do
          local conn_line
          if conn.type == 'scene' then
            conn_line = string.format('  │  └─ %s %s → %s.%s() [%s:%d]',
              config.icons.connection, conn.from_node or 'unknown', conn.target, conn.method,
              conn.source_file, conn.source_line)
          else
            conn_line = string.format('  │  └─ %s %s.%s() [%s:%d]',
              config.icons.connection, conn.target, conn.method,
              conn.source_file, conn.source_line)
          end
          table.insert(lines, conn_line)
          table.insert(line_data, {
            type = 'connection',
            file = conn.source_file,
            line = conn.source_line,
            data = conn
          })
        end
      end

      table.insert(lines, '  │')
      table.insert(line_data, { type = 'spacing' })
    end

    table.insert(lines, '')
    table.insert(line_data, { type = 'spacing' })
  end

  -- Add footer with instructions
  table.insert(lines, '')
  table.insert(line_data, { type = 'spacing' })

  table.insert(lines, '──────────────────────────────────────')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, 'Keymaps:')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  <CR>  - Go to definition/connection')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  <Tab> - Expand/collapse')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  zc    - Collapse all')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  zo    - Expand all')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  q     - Close window')
  table.insert(line_data, { type = 'footer' })

  table.insert(lines, '  r     - Refresh')
  table.insert(line_data, { type = 'footer' })

  -- Verify sync
  if #lines ~= #line_data then
    vim.notify(string.format("ERROR: lines=%d but line_data=%d", #lines, #line_data), vim.log.levels.ERROR)
  end

  -- Set content
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)

  -- Store line data in buffer variable
  vim.api.nvim_buf_set_var(state.buf, 'godot_signals_line_data', line_data)

  vim.bo[state.buf].modifiable = false

  -- Add syntax highlighting
  M.setup_highlights()
end

-- Setup buffer keymaps
function M.setup_keymaps(buf, state, config)
  local opts = { buffer = buf, silent = true, noremap = true }

  -- Close window
  vim.keymap.set('n', 'q', function()
    vim.notify("Q pressed!", vim.log.levels.INFO)
    if state.win and vim.api.nvim_win_is_valid(state.win) then
      vim.api.nvim_win_close(state.win, true)
      state.win = nil
    end
  end, opts)

  -- Go to definition/connection
  vim.keymap.set('n', '<CR>', function()
    vim.notify("CR pressed!", vim.log.levels.INFO)
    local ok, err = pcall(M.goto_location, state)
    if not ok then
      vim.notify("Error in goto_location: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, opts)

  -- Expand/collapse
  vim.keymap.set('n', '<Tab>', function()
    vim.notify("Tab pressed!", vim.log.levels.INFO)
    local ok, err = pcall(M.toggle_expand, state, config)
    if not ok then
      vim.notify("Error in toggle_expand: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, opts)

  -- Refresh
  vim.keymap.set('n', 'r', function()
    vim.notify("R pressed!", vim.log.levels.INFO)
    require('custom.home_brew.godot_signals').refresh()
  end, opts)

  -- Collapse all
  vim.keymap.set('n', 'zc', function()
    vim.notify("Collapsing all...", vim.log.levels.INFO)
    local ok, err = pcall(M.collapse_all, state, config)
    if not ok then
      vim.notify("Error in collapse_all: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, opts)

  -- Expand all
  vim.keymap.set('n', 'zo', function()
    vim.notify("Expanding all...", vim.log.levels.INFO)
    local ok, err = pcall(M.expand_all, state, config)
    if not ok then
      vim.notify("Error in expand_all: " .. tostring(err), vim.log.levels.ERROR)
    end
  end, opts)
end

-- Go to file location
function M.goto_location(state)
  vim.notify("goto_location called", vim.log.levels.INFO)

  local ok, line_data = pcall(vim.api.nvim_buf_get_var, state.buf, 'godot_signals_line_data')
  if not ok then
    vim.notify("No line data found", vim.log.levels.ERROR)
    return
  end

  -- DEBUG: Print all line_data around cursor
  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local line_idx = cursor[1]

  vim.notify("=== LINE DATA DUMP ===", vim.log.levels.INFO)
  for i = math.max(1, line_idx - 3), math.min(#line_data, line_idx + 3) do
    local d = line_data[i]
    vim.notify(string.format("Line %d: type=%s, file=%s", i, d.type or "nil", d.file or "nil"), vim.log.levels.INFO)
  end
  vim.notify("=== END DUMP ===", vim.log.levels.INFO)

  -- rest of function...

  vim.notify("Got line_data", vim.log.levels.INFO)

  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local line_idx = cursor[1]

  vim.notify("Cursor at line " .. line_idx, vim.log.levels.INFO)

  local data = line_data[line_idx]
  if not data then
    vim.notify("No data for line " .. line_idx, vim.log.levels.ERROR)
    return
  end

  vim.notify("Data type: " .. (data.type or "nil"), vim.log.levels.INFO)
  vim.notify("Data file: " .. (data.file or "nil"), vim.log.levels.INFO)

  -- Check if this line has a file location
  if not data.file or not data.line then
    vim.notify("Line has no file/line info (type: " .. (data.type or "nil") .. ")", vim.log.levels.WARN)
    return
  end

  vim.notify("Trying to open: " .. data.file .. ":" .. data.line, vim.log.levels.INFO)

  -- Build the full file path
  local project_root = require('custom.home_brew.godot_signals').state.project_root or vim.fn.getcwd()
  local full_path = project_root .. '/' .. data.file

  vim.notify("Full path: " .. full_path, vim.log.levels.INFO)

  -- Find a window to open the file in (not the signals window)
  local target_win = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if win ~= state.win then
      target_win = win
      break
    end
  end

  if target_win then
    vim.notify("Opening in existing window", vim.log.levels.INFO)
    vim.api.nvim_set_current_win(target_win)
    vim.cmd('edit ' .. vim.fn.fnameescape(full_path))
    vim.api.nvim_win_set_cursor(target_win, { data.line, 0 })
    vim.cmd('normal! zz')
  else
    vim.notify("Creating new split", vim.log.levels.INFO)
    vim.cmd('vsplit ' .. vim.fn.fnameescape(full_path))
    vim.api.nvim_win_set_cursor(0, { data.line, 0 })
    vim.cmd('normal! zz')
  end
end

-- Toggle expand/collapse for signal
function M.toggle_expand(state, config)
  local line_data = vim.api.nvim_buf_get_var(state.buf, 'godot_signals_line_data')
  local cursor = vim.api.nvim_win_get_cursor(state.win)
  local line_idx = cursor[1]

  local data = line_data[line_idx]
  if data and data.type == 'signal' then
    local signal_name = data.signal_name
    M.tree_state[signal_name] = not (M.tree_state[signal_name] ~= false)
    M.render(state, config)

    -- Restore cursor position
    vim.api.nvim_win_set_cursor(state.win, cursor)
  end
end

-- Collapse all signals
function M.collapse_all(state, config)
  -- Set all signals to collapsed
  for signal_name, _ in pairs(state.signals) do
    M.tree_state[signal_name] = false
  end

  -- Re-render
  M.render(state, config)

  vim.notify("Collapsed all signals", vim.log.levels.INFO)
end

-- Expand all signals
function M.expand_all(state, config)
  -- Set all signals to expanded
  for signal_name, _ in pairs(state.signals) do
    M.tree_state[signal_name] = true
  end

  -- Re-render
  M.render(state, config)

  vim.notify("Expanded all signals", vim.log.levels.INFO)
end

-- Setup syntax highlighting
function M.setup_highlights()
  vim.cmd([[
    syntax match GodotSignalsHeader /^╔.*╗$/
    syntax match GodotSignalsHeader /^║.*║$/
    syntax match GodotSignalsHeader /^╚.*╝$/
    syntax match GodotSignalsIcon /[📡🔗📄🎬▼▶]/
    syntax match GodotSignalsTree /[│└─]/
    syntax match GodotSignalsBuiltin /\[built-in\]/
    syntax match GodotSignalsFile /\v[a-zA-Z0-9_\/.-]+\.(gd|tscn)/
    syntax match GodotSignalsLineNum /:\d\+/

    highlight link GodotSignalsHeader Title
    highlight link GodotSignalsIcon Special
    highlight link GodotSignalsTree Comment
    highlight link GodotSignalsBuiltin Comment
    highlight link GodotSignalsFile String
    highlight link GodotSignalsLineNum Number
  ]])
end

return M
