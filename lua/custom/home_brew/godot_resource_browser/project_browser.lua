-- lua/custom/home_brew/godot_resource_browser/project_browser.lua
local M = {}

-- Find the project root by looking for project.godot
local function find_project_root()
    local current_file = vim.api.nvim_buf_get_name(0)
    local current_dir = vim.fn.fnamemodify(current_file, ":p:h")

    -- Walk up directories looking for project.godot
    local max_depth = 10
    for _ = 1, max_depth do
        local project_file = current_dir .. "/project.godot"
        if vim.fn.filereadable(project_file) == 1 then
            return current_dir
        end

        local parent = vim.fn.fnamemodify(current_dir, ":h")
        if parent == current_dir then
            break -- Reached root
        end
        current_dir = parent
    end

    -- Fallback to current working directory
    return vim.fn.getcwd()
end

-- Recursively find all .tres files in directory
local function find_tres_files(directory)
    local files = {}

    -- Use vim's globpath to find files recursively
    local found = vim.fn.globpath(directory, "**/*.tres", false, true)

    for _, filepath in ipairs(found) do
        -- Get relative path from project root
        local relative = filepath:gsub("^" .. vim.pesc(directory) .. "/", "")
        table.insert(files, {
            path = filepath,
            relative = relative,
            name = vim.fn.fnamemodify(filepath, ":t"),
            dir = vim.fn.fnamemodify(filepath, ":h:t"),
        })
    end

    return files
end

-- Get resource type from a .tres file without full parsing
local function quick_parse_type(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return "Unknown"
    end

    -- Read just the first few lines
    local count = 0
    for line in file:lines() do
        count = count + 1
        if count > 10 then
            break
        end

        local res_type = line:match('type="([^"]+)"')
        if res_type then
            file:close()
            return res_type
        end
    end

    file:close()
    return "Unknown"
end

function M.render_project_browser()
    local project_root = find_project_root()
    vim.notify("Scanning project: " .. project_root, vim.log.levels.INFO)

    local files = find_tres_files(project_root)

    if #files == 0 then
        vim.notify("No .tres files found in project", vim.log.levels.WARN)
        return
    end

    -- Sort by directory then name
    table.sort(files, function(a, b)
        if a.dir == b.dir then
            return a.name < b.name
        end
        return a.dir < b.dir
    end)

    -- Open a new split
    vim.cmd("vsplit")
    vim.cmd("enew")

    local buf = vim.api.nvim_get_current_buf()

    -- Set buffer options
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "godot-resource-list"

    vim.api.nvim_buf_set_name(buf, "Godot Resources")

    -- Build display
    local lines = {}

    -- Header
    table.insert(lines, "╔════════════════════════════════════════════════════════╗")
    table.insert(lines, string.format("║ Godot Project Resources                               ║"))
    table.insert(lines, string.format("║ Found: %-47d ║", #files))
    table.insert(lines, "╚════════════════════════════════════════════════════════╝")
    table.insert(lines, "")

    -- Group files by directory
    local current_dir = nil
    for i, file in ipairs(files) do
        if file.dir ~= current_dir then
            current_dir = file.dir
            if i > 1 then
                table.insert(lines, "")
            end
            table.insert(lines, "📁 " .. current_dir .. "/")
            table.insert(lines, "─────────────────────────────────────────────────────────")
        end

        -- Get resource type (this might be slow for many files)
        local res_type = quick_parse_type(file.path)

        table.insert(lines, string.format("  [%d] %s", i, file.name))
        table.insert(lines, string.format("      Type: %s", res_type))
    end

    -- Footer
    table.insert(lines, "")
    table.insert(lines, "─────────────────────────────────────────────────────────")
    table.insert(lines, "  <CR>: open  |  q: close  |  /: search  |  r: refresh")
    table.insert(lines, "─────────────────────────────────────────────────────────")

    -- Set content
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    -- Store files in buffer variable for navigation
    vim.b[buf].godot_files = files
    vim.b[buf].project_root = project_root

    -- Set up keymaps
    vim.keymap.set("n", "q", ":close<CR>", {
        buffer = buf,
        silent = true,
        desc = "Close resource list"
    })

    vim.keymap.set("n", "r", function()
        vim.cmd("close")
        M.render_project_browser()
    end, {
        buffer = buf,
        silent = true,
        desc = "Refresh resource list"
    })

    vim.keymap.set("n", "<CR>", function()
        M.open_resource_at_cursor()
    end, {
        buffer = buf,
        silent = true,
        desc = "Open resource"
    })

    vim.keymap.set("n", "i", function()
        M.show_resource_info_at_cursor()
    end, {
        buffer = buf,
        silent = true,
        desc = "Show resource info"
    })

    -- Search functionality
    vim.keymap.set("n", "/", function()
        vim.fn.setreg("/", "")
        vim.cmd("normal! /")
    end, {
        buffer = buf,
        silent = false,
        desc = "Search resources"
    })

    -- Syntax highlighting
    vim.cmd([[
        syntax match GodotResourceListHeader /^╔.*╗$/
        syntax match GodotResourceListHeader /^╚.*╝$/
        syntax match GodotResourceListHeader /^║.*║$/
        syntax match GodotResourceListDir /^📁.*$/
        syntax match GodotResourceListSeparator /^─.*$/
        syntax match GodotResourceListIndex /^\s*\[\d\+\]/
        syntax match GodotResourceListType /Type:.*$/

        highlight link GodotResourceListHeader Title
        highlight link GodotResourceListDir Directory
        highlight link GodotResourceListSeparator Comment
        highlight link GodotResourceListIndex Number
        highlight link GodotResourceListType Type
    ]])
end

function M.open_resource_at_cursor()
    local buf = vim.api.nvim_get_current_buf()
    local files = vim.b[buf].godot_files

    if not files then
        vim.notify("No files data found", vim.log.levels.ERROR)
        return
    end

    -- Get current line
    local line = vim.api.nvim_get_current_line()

    -- Extract index from [N] format
    local index = line:match("%[(%d+)%]")
    if not index then
        vim.notify("No resource on this line", vim.log.levels.WARN)
        return
    end

    index = tonumber(index)
    if not files[index] then
        vim.notify("Invalid resource index", vim.log.levels.ERROR)
        return
    end

    local file = files[index]

    -- Close the browser window
    vim.cmd("close")

    -- Open the file
    vim.cmd("edit " .. vim.fn.fnameescape(file.path))
end

function M.show_resource_info_at_cursor()
    local buf = vim.api.nvim_get_current_buf()
    local files = vim.b[buf].godot_files

    if not files then
        vim.notify("No files data found", vim.log.levels.ERROR)
        return
    end

    -- Get current line
    local line = vim.api.nvim_get_current_line()

    -- Extract index from [N] format
    local index = line:match("%[(%d+)%]")
    if not index then
        vim.notify("No resource on this line", vim.log.levels.WARN)
        return
    end

    index = tonumber(index)
    if not files[index] then
        vim.notify("Invalid resource index", vim.log.levels.ERROR)
        return
    end

    local file = files[index]

    -- Parse and show resource info
    local parser = require("custom.home_brew.godot_resource_browser.parser")
    local ui = require("custom.home_brew.godot_resource_browser.ui")

    local resource = parser.parse_resource(file.path)

    if not resource then
        vim.notify("Failed to parse resource", vim.log.levels.ERROR)
        return
    end

    -- Close browser and show info
    vim.cmd("close")
    ui.render(resource)
end

return M
