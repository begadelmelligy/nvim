local M = {}

-- Parse a GDScript file for signal definitions and connections
function M.parse_gd_file(filepath, signals, connections, config)
  local file = io.open(filepath, 'r')
  if not file then return end

  local content = file:read('*all')
  file:close()

  local relative_path = filepath:gsub(vim.fn.getcwd() .. '/', '')

  if config.debug then
    print("Parsing: " .. relative_path)
  end

  -- Find signal definitions - line by line for accuracy
  local line_num = 0
  for line in content:gmatch('[^\r\n]+') do
    line_num = line_num + 1

    -- Match signal definitions more carefully
    -- Pattern: signal signal_name or signal signal_name(params)
    local signal_name = line:match('^%s*signal%s+([%w_]+)')
    if signal_name then
      if config.debug then
        print("  Found signal: " .. signal_name .. " at line " .. line_num)
      end
      if not signals[signal_name] then
        signals[signal_name] = {
          name = signal_name,
          defined_in = {},
          connections = {},
          emissions = {}
        }
      end
      table.insert(signals[signal_name].defined_in, {
        file = relative_path,
        line = line_num
      })
    end
  end

  -- Find signal emissions - more robust pattern matching
  line_num = 0
  for line in content:gmatch('[^\r\n]+') do
    line_num = line_num + 1

    -- Match emit_signal calls
    -- Handles: emit_signal("signal_name") or emit_signal('signal_name')
    local signal_name = line:match('emit_signal%s*%(%s*["\']([%w_]+)["\']')
    if signal_name and signals[signal_name] then
      table.insert(signals[signal_name].emissions, {
        file = relative_path,
        line = line_num
      })
    end
  end

  -- Find signal connections in code
  local line_num = 0
  for line in content:gmatch('[^\r\n]+') do
    line_num = line_num + 1

    -- Pattern 1: Godot 3 style - node.connect("signal_name", target, "method_name")
    local signal_name, target, method = line:match(
      '%.connect%s*%(%s*["\']([%w_]+)["\']%s*,%s*([^,%)]+)%s*,%s*["\']([%w_]+)["\']')

    if signal_name and target and method then
      -- Clean up target (remove whitespace)
      target = target:gsub('%s+', '')

      table.insert(connections, {
        signal = signal_name,
        target = target,
        method = method,
        source_file = relative_path,
        source_line = line_num,
        type = 'code'
      })
    else
      -- Pattern 2: Godot 4 style - signal_name.connect(method_name)
      signal_name, method = line:match('([%w_]+)%.connect%s*%(%s*([%w_]+)%s*%)')
      if signal_name and method then
        table.insert(connections, {
          signal = signal_name,
          target = 'self',
          method = method,
          source_file = relative_path,
          source_line = line_num,
          type = 'code'
        })
      end
    end
  end
end

-- Parse a scene file for signal connections
function M.parse_tscn_file(filepath, connections, config)
  local file = io.open(filepath, 'r')
  if not file then return end

  local content = file:read('*all')
  file:close()

  local relative_path = filepath:gsub(vim.fn.getcwd() .. '/', '')

  -- Parse connections in scene format
  -- [connection signal="signal_name" from="NodePath" to="NodePath" method="method_name"]
  local line_num = 0
  for line in content:gmatch('[^\r\n]+') do
    line_num = line_num + 1

    if line:match('%[connection') then
      local signal_name = line:match('signal="([^"]+)"')
      local from_node = line:match('from="([^"]+)"')
      local to_node = line:match('to="([^"]+)"')
      local method = line:match('method="([^"]+)"')

      if signal_name and method then
        table.insert(connections, {
          signal = signal_name,
          from_node = from_node or 'unknown',
          target = to_node or 'unknown',
          method = method,
          source_file = relative_path,
          source_line = line_num,
          type = 'scene'
        })
      end
    end
  end
end

-- Link connections to their signal definitions
function M.link_connections(signals, connections)
  for _, conn in ipairs(connections) do
    if signals[conn.signal] then
      table.insert(signals[conn.signal].connections, conn)
    else
      -- Signal not found, might be built-in or from parent class
      signals[conn.signal] = {
        name = conn.signal,
        defined_in = {},
        connections = { conn },
        emissions = {},
        is_builtin = true
      }
    end
  end
end

-- Find line number of a pattern in content
function M.find_line_number(content, search_term, context)
  local line_num = 0
  for line in content:gmatch('[^\r\n]+') do
    line_num = line_num + 1
    if line:match(context) and line:match(search_term) then
      return line_num
    end
  end
  return 1
end

return M
