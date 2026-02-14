-- lua/custom/home_brew/godot_resource_browser/ui.lua

local M = {}

local function render_properties(properties, depth)
    depth = depth or 0
    local lines = {}
    local indent = string.rep("  ", depth)

    -- Sort properties alphabetically
    local sorted_keys = {}
    for key, _ in pairs(properties) do
        table.insert(sorted_keys, key)
    end
    table.sort(sorted_keys)

    for _, key in ipairs(sorted_keys) do
        local value = properties[key]
        table.insert(lines, string.format("%s%s = %s", indent, key, value))
    end

    return lines
end

function M.render(resource)
    if not resource then
        vim.notify("No resource to render", vim.log.levels.ERROR)
        return
    end

    -- Open a vertical split
    vim.cmd("vsplit")
    vim.cmd("enew")

    local buf = vim.api.nvim_get_current_buf()

    -- Set buffer options
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "godot-resource"

    -- Set buffer name
    local filename = resource.filepath:match("([^/\\]+)$") or resource.filepath
    vim.api.nvim_buf_set_name(buf, "Godot Resource: " .. filename)

    -- Build the display
    local lines = {}

    -- Header
    table.insert(lines, "╔════════════════════════════════════════════════════════╗")
    table.insert(lines, string.format("║ Resource Type: %-39s ║", resource.type))
    table.insert(lines, string.format("║ File: %-47s ║", filename))
    table.insert(lines, "╚════════════════════════════════════════════════════════╝")
    table.insert(lines, "")

    -- Properties
    if next(resource.properties) then
        table.insert(lines, "📋 Properties:")
        table.insert(lines, "─────────────────────────────────────────────────────────")
        local prop_lines = render_properties(resource.properties, 1)
        for _, line in ipairs(prop_lines) do
            table.insert(lines, line)
        end
        table.insert(lines, "")
    end

    -- External Resources
    if #resource.external_resources > 0 then
        table.insert(lines, "🔗 External Resources:")
        table.insert(lines, "─────────────────────────────────────────────────────────")
        for i, ext_res in ipairs(resource.external_resources) do
            local filename_only = ext_res.path:match("([^/]+)$") or ext_res.path
            table.insert(lines, string.format("  [%d] %s: %s", i, ext_res.type, filename_only))
            table.insert(lines, string.format("      Path: %s", ext_res.path))
        end
        table.insert(lines, "")
    end

    -- Sub-resources
    if #resource.sub_resources > 0 then
        table.insert(lines, "📦 Sub-resources:")
        table.insert(lines, "─────────────────────────────────────────────────────────")
        for i, sub_res in ipairs(resource.sub_resources) do
            table.insert(lines, string.format("  [%d] %s (id: %s)", i, sub_res.type, sub_res.id))
            if next(sub_res.properties) then
                local sub_prop_lines = render_properties(sub_res.properties, 2)
                for _, line in ipairs(sub_prop_lines) do
                    table.insert(lines, line)
                end
            end
            table.insert(lines, "")
        end
    end

    -- Footer with keymaps
    table.insert(lines, "")
    table.insert(lines, "─────────────────────────────────────────────────────────")
    table.insert(lines, "  q: close  |  r: refresh  |  <CR>: jump to resource")
    table.insert(lines, "─────────────────────────────────────────────────────────")

    -- Set the content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Make buffer read-only
    vim.bo[buf].modifiable = false

    -- Set up keymaps
    vim.keymap.set("n", "q", ":close<CR>", {
        buffer = buf,
        silent = true,
        desc = "Close resource viewer"
    })

    vim.keymap.set("n", "r", function()
        M.refresh_current_buffer()
    end, {
        buffer = buf,
        silent = true,
        desc = "Refresh resource view"
    })

    -- Store resource info in buffer variable for navigation
    vim.b[buf].godot_resource = resource

    -- Syntax highlighting (basic)
    vim.cmd([[
        syntax match GodotResourceHeader /^╔.*╗$/
        syntax match GodotResourceHeader /^╚.*╝$/
        syntax match GodotResourceHeader /^║.*║$/
        syntax match GodotResourceSection /^[📋🔗📦].*:$/
        syntax match GodotResourceSeparator /^─.*$/
        syntax match GodotResourceProperty /^\s*\w\+\s*=/
        syntax match GodotResourceValue /=\s*\zs.*/

        highlight link GodotResourceHeader Title
        highlight link GodotResourceSection Function
        highlight link GodotResourceSeparator Comment
        highlight link GodotResourceProperty Identifier
        highlight link GodotResourceValue String
    ]])
end

function M.refresh_current_buffer()
    local buf = vim.api.nvim_get_current_buf()
    local resource = vim.b[buf].godot_resource

    if not resource or not resource.filepath then
        vim.notify("No resource info found", vim.log.levels.WARN)
        return
    end

    -- Find the original .tres file window
    local tres_file = resource.filepath

    local parser = require("custom.home_brew.godot_resource_browser.parser")
    local new_resource = parser.parse_resource(tres_file)

    if not new_resource then
        vim.notify("Failed to refresh resource", vim.log.levels.ERROR)
        return
    end

    -- Close current window and render fresh
    vim.cmd("close")
    M.render(new_resource)

    vim.notify("Resource refreshed", vim.log.levels.INFO)
end

return M
