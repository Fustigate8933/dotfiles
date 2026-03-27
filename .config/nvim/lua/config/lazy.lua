local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then -- if the folder at lazy path doesn't exist
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then -- if exit code is not 0 a.k.a. an error
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath) -- adds lazy.nvim plugin to neovim's runtime path

require("config.options")
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	checker = {
		enabled = false, -- auto check for updates
		notify = true, -- notify when new updates are found
		frequency = 7200, -- check for updates every 2 hours
	},
})

-- colors
vim.cmd.colorscheme("sonokai")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#999999" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#ffffff" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#999999" })
