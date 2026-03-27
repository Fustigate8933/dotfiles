return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = "<cmd>TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua", "vim", "vimdoc", "python", "javascript", "html", "markdown", "markdown_inline", "vue", "c", "cpp", "typescript", "json", "bash", "luadoc", "tsx", "vim", "yaml", "qmljs"
				},
				highlight = { enable = true },
				indent = { enable = true },
				auto_install = true,

				textobjects = {
					move = { enable = true, set_jumps = true },
					select = { enable = true, lookahead = true },
					swap = { enable = true },
				},
			})

			-- molten.nvim
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown" },
				callback = function()
					vim.keymap.set("n", "[b", function()
						require("nvim-treesitter.textobjects.move").goto_previous_start("@code_cell.inner")
					end, { buffer = true, desc = "previous code block" })

					vim.keymap.set("n", "]b", function()
						require("nvim-treesitter.textobjects.move").goto_next_start("@code_cell.inner")
					end, { buffer = true, desc = "next code block" })

					vim.keymap.set("x", "ib", function()
						require("nvim-treesitter.textobjects.select").select_textobject("@code_cell.inner", "x")
					end, { buffer = true, desc = "in block" })

					vim.keymap.set("x", "ab", function()
						require("nvim-treesitter.textobjects.select").select_textobject("@code_cell.outer", "x")
					end, { buffer = true, desc = "around block" })

					vim.keymap.set("n", "<leader>sn", function()
						require("nvim-treesitter.textobjects.swap").swap_next("@code_cell.outer")
					end, { buffer = true })

					vim.keymap.set("n", "<leader>sp", function()
						require("nvim-treesitter.textobjects.swap").swap_previous("@code_cell.outer")
					end, { buffer = true })
				end,
			})
		end
	},
	{
		"windwp/nvim-ts-autotag",
		opts = {}
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects", -- copied from lazyvim config
		enabled = true,
		config = function()
			-- When in diff mode, we want to use the default
			-- vim text objects c & C instead of the treesitter ones.
			local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
			local configs = require("nvim-treesitter.configs")
			for name, fn in pairs(move) do
				if name:find("goto") == 1 then
					move[name] = function(q, ...)
						if vim.wo.diff then
							local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
							for key, query in pairs(config or {}) do
								if q == query and key:find("[%]%[][cC]") then
									vim.cmd("normal! " .. key)
									return
								end
							end
						end
						return fn(q, ...)
					end
				end
			end
		end,
	}
}
