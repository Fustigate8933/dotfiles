return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	build = ":TSUpdate",
	config = function()
		local config = require("nvim-treesitter.configs")

		config.setup({
			ensure_installed = { "lua", "vim", "vimdoc", "python", "javascript", "html", "markdown", "markdown_inline", "vue", "c" },
			highlight = { enable = true },
			indent = { enable = true },
			auto_install = true,
			textobjects = {
				move = {
					enable = true,
					set_jumps = true, -- you can change this if you want.
					goto_next_start = {
						--- ... other keymaps
						["]b"] = { query = "@code_cell.inner", desc = "next code block" },
					},
					goto_previous_start = {
						--- ... other keymaps
						["[b"] = { query = "@code_cell.inner", desc = "previous code block" },
					},
				},
				select = {
					enable = true,
					lookahead = true, -- you can change this if you want
					keymaps = {
						--- ... other keymaps
						["ib"] = { query = "@code_cell.inner", desc = "in block" },  -- e.g. vib will select the insides of an entire code cell
						["ab"] = { query = "@code_cell.outer", desc = "around block" },
					},
				},
				swap = { -- Swap only works with code blocks that are under the same
					-- markdown header
					enable = true,
					swap_next = {
						--- ... other keymap
						["<leader>sn"] = "@code_cell.outer",
					},
					swap_previous = {
						--- ... other keymap
						["<leader>sp"] = "@code_cell.outer",
					},
				},
			},
		})

		vim.keymap.set("n", "]b", function()
			require("nvim-treesitter.configs").textobjects.move.goto_next_start[""]()
		end)
	end,
}
