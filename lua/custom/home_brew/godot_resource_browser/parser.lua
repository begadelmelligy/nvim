-- lua/custom/home_brew/godot_resource_browser/parser.lua
local M = {}

-- Parse a property line like: albedo_color = Color(0.8, 0.6, 0.4, 1)
local function parse_property(line)
    local key, value = line:match("^([%w_]+)%s*=%s*(.+)$")
    if key and value then
        return key:gsub("^%s*(.-)%s*$", "%1"), value:gsub("^%s*(.-)%s*$", "%1")
    end
    return nil, nil
end

-- Parse resource type from header: [gd_resource type="StandardMaterial3D" ...]
local function parse_resource_type(line)
    return line:match('type="([^"]+)"')
end

-- Parse external resource: [ext_resource type="Texture2D" path="res://..." id="1_abc"]
local function parse_ext_resource(line)
    local res_type = line:match('type="([^"]+)"')
    local path = line:match('path="([^"]+)"')
    local id = line:match('id="([^"]+)"')

    if res_type and path and id then
        return {
            type = res_type,
            path = path,
            id = id,
        }
    end
    return nil
end

-- Parse sub-resource header: [sub_resource type="GDScript" id="abc123"]
local function parse_sub_resource(line)
    local res_type = line:match('type="([^"]+)"')
    local id = line:match('id="([^"]+)"')

    if res_type and id then
        return {
            type = res_type,
            id = id,
        }
    end
    return nil
end

function M.parse_resource(filepath)
    local file = io.open(filepath, "r")
    if not file then
        vim.notify("Could not open file: " .. filepath, vim.log.levels.ERROR)
        return nil
    end
    file:close()

    local lines = vim.fn.readfile(filepath)

    local resource = {
        type = "Unknown",
        filepath = filepath,
        properties = {},
        external_resources = {},
        sub_resources = {},
    }

    local current_section = "header"
    local current_sub_resource = nil

    for _, line in ipairs(lines) do
        -- Trim whitespace
        line = line:gsub("^%s*(.-)%s*$", "%1")

        -- Skip empty lines and comments
        if line == "" or line:match("^;") then
            goto continue
        end

        -- Resource type header
        if line:match("^%[gd_resource") then
            local res_type = parse_resource_type(line)
            if res_type then
                resource.type = res_type
            end
            current_section = "header"

            -- External resource
        elseif line:match("^%[ext_resource") then
            local ext_res = parse_ext_resource(line)
            if ext_res then
                table.insert(resource.external_resources, ext_res)
            end
            current_section = "ext_resource"

            -- Sub-resource
        elseif line:match("^%[sub_resource") then
            local sub_res = parse_sub_resource(line)
            if sub_res then
                current_sub_resource = sub_res
                current_sub_resource.properties = {}
                table.insert(resource.sub_resources, current_sub_resource)
            end
            current_section = "sub_resource"

            -- Main resource properties section
        elseif line:match("^%[resource%]") then
            current_section = "resource"
            current_sub_resource = nil

            -- Property line
        else
            local key, value = parse_property(line)
            if key and value then
                if current_section == "sub_resource" and current_sub_resource then
                    current_sub_resource.properties[key] = value
                elseif current_section == "resource" then
                    resource.properties[key] = value
                end
            end
        end

        ::continue::
    end

    return resource
end

-- Extract the filename from a path
function M.get_filename(path)
    return path:match("([^/\\]+)$") or path
end

-- Check if a value is a resource reference
function M.is_resource_reference(value)
    return value:match("ExtResource%(") or value:match("SubResource%(")
end

-- Extract resource ID from reference like: ExtResource("1_abc123")
function M.extract_resource_id(value)
    return value:match('Resource%("([^"]+)"%)')
end

return M
