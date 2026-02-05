--
-- Force cursor shape changes
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"
vim.opt.termguicolors = true

-- Force correct cursor shape escape sequences for WezTerm on Windows
vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20"

local function set_cursor()
  local mode = vim.fn.mode()
  local ESC = string.char(27)

  if mode == "i" or mode == "R" then
    -- Insert/Replace mode: vertical bar
    io.write(ESC .. "[6 q")
  else
    -- Normal mode: block
    io.write(ESC .. "[2 q")
  end
  io.flush()
end

-- Set cursor on mode change
vim.api.nvim_create_autocmd({ "ModeChanged", "VimEnter" }, {
  callback = set_cursor,
})

-- Also set on insert enter/leave for redundancy
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    local ESC = string.char(27)
    io.write(ESC .. "[6 q")
    io.flush()
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    local ESC = string.char(27)
    io.write(ESC .. "[2 q")
    io.flush()
  end,
})
