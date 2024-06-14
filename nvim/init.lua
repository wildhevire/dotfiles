require("platform")
require("opts")
require("lazy_config")
require("keymaps")
vim.cmd.colorscheme "catppuccin"

-- Handle Godot project--
-------------------------
if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
	local addr = "./godot.pipe"
	if vim.fn.has("win32") == 1 then
		-- Windows can't pipe so use localhost. Make sure this is configured in Godot
		addr = "127.0.0.1:6004"
	end
    print("Opened Godot Project")
	vim.fn.serverstart(addr)
end
