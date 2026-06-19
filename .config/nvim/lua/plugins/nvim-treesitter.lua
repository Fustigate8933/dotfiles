return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({})

			-- Install parsers
			require("nvim-treesitter").install({
				"lua", "vim", "vimdoc", "python", "javascript", "html", "markdown",
				"markdown_inline", "vue", "c", "cpp", "typescript", "json", "bash",
				"luadoc", "tsx", "yaml", "qmljs", "java"
			})

			-- Enable treesitter highlighting for all supported filetypes
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})
		end,
	},
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},
}
