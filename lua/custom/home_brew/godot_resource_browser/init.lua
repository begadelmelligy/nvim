-- lua/custom/home_brew/godot_resource_browser/init.lua
local M = {}

function M.show_resource_info()
    local parser = require("custom.home_brew.godot_resource_browser.parser")
    local ui = require("custom.home_brew.godot_resource_browser.ui")

    local file = vim.api.nvim_buf_get_name(0)

    -- Check if file is a .tres file
    if not file:match("%.tres$") then
        vim.notify("Not a .tres file: " .. file, vim.log.levels.WARN)
        return
    end

    local resource = parser.parse_resource(file)

    if not resource then
        vim.notify("Failed to parse resource file", vim.log.levels.ERROR)
        return
    end

    ui.render(resource)
end

function M.show_project_resources()
    local project_browser = require("custom.home_brew.godot_resource_browser.project_browser")
    project_browser.render_project_browser()
end

function M.setup(opts)
    opts = opts or {}

    -- Create an autocommand group
    local group = vim.api.nvim_create_augroup("GodotResourceBrowser", { clear = true })

    -- Set up the autocmd for .tres files
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        group = group,
        pattern = "*.tres",
        callback = function(args)
            local bufnr = args.buf

            -- Keymap to show resource info
            vim.keymap.set("n", "<Space>gr", function()
                M.show_resource_info()
            end, {
                buffer = bufnr,
                desc = "Show Godot Resource Info",
                noremap = true,
                silent = true,
            })

            -- Alternative keymap
            vim.keymap.set("n", "<Space>gi", function()
                M.show_resource_info()
            end, {
                buffer = bufnr,
                desc = "Show Godot Resource Info",
                noremap = true,
                silent = true,
            })
        end,
    })

    -- Global keymap for project browser (works anywhere in Godot project)
    vim.keymap.set("n", "<Space>gp", function()
        M.show_project_resources()
    end, {
        desc = "Show Godot Project Resources",
        noremap = true,
        silent = true,
    })

    -- Alternative global keymap
    vim.keymap.set("n", "<Space>gf", function()
        M.show_project_resources()
    end, {
        desc = "Find Godot Resources",
        noremap = true,
        silent = true,
    })

    vim.notify("Godot Resource Browser loaded! <Space>gr = info, <Space>gp = project browser", vim.log.levels.INFO)
end

return M
