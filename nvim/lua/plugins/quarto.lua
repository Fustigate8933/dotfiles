return {
	"quarto-dev/quarto-nvim",
	dependencies = {
		"jmbuhr/otter.nvim",
		"hrsh7th/nvim-cmp",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		local otter = require("otter")
		local languages = { "python", "lua" }
		local completion = true
		local tsquery = nil
		local diagnostics = true
		otter.activate(languages, completion, diagnostics, tsquery)

		local quarto = require("quarto")
		quarto.setup({
			lspFeatures = {
				enabled = true,
				-- NOTE: put whatever languages you want here:
				languages = { "r", "python", "rust", "html" },
				chunks = "all",
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			keymap = {
				-- NOTE: setup your own keymaps:
				hover = "H",
				definition = "gd",
				rename = "<leader>rn",
				references = "gr",
				format = "<leader>gf",
			},
			codeRunner = {
				enabled = true,
				default_method = "molten",
			},
		})

		local runner = require("quarto.runner")
		vim.g.localleader = "\\"
		vim.keymap.set("n", "<localleader>rc", runner.run_cell, { desc = "run cell", silent = true })
		vim.keymap.set("n", "<localleader>ra", runner.run_above, { desc = "run cell and above", silent = true })
		vim.keymap.set("n", "<localleader>rA", runner.run_all, { desc = "run all cells", silent = true })
		vim.keymap.set("n", "<localleader>rl", runner.run_line, { desc = "run line", silent = true })
		vim.keymap.set("v", "<localleader>r", runner.run_range, { desc = "run visual range", silent = true })
		vim.keymap.set("n", "<localleader>nc", "A<cr>```python<cr><cr>```<cr><esc>kki", {})


		vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>:lua require('quarto').activate()<CR>", {})
		vim.cmd("unmap <C-n>")
		vim.keymap.set("n", "<C-n>", ":Neotree toggle<CR>", {})

		vim.keymap.set("n", "<localleader>RA", function()
			runner.run_all(true)
		end, { desc = "run all cells of all languages", silent = true })
	end,
	ft = { "quarto", "markdown" },
}
