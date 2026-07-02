--Godot specific functions
vim.api.nvim_create_user_command("Godot", function()
	vim.fn.jobstart({ "E:/Godot/Godot_v4.5.1-stable_win64.exe", "--editor" }, { detach = true })
end, {})
