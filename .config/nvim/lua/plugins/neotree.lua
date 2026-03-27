return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	lazy = false,
	opts = {
		filesystem = {
			window = {
				auto_expand_width = false,
			},
			filtered_items = {
				visible = true, -- This is what you want: If you set this to `true`, all "hide" just mean "dimmed out"
				hide_dotfiles = false,
				hide_gitignored = true,
			},
			commands = {
				-- Override delete to use trash instead of rm
				delete = function(state)
					local path = state.tree:get_node().path
					local function get_user_input_char()
						local c = vim.fn.getchar()
						return vim.fn.nr2char(c)
					end
					print("Trash " .. path .. " ? y/n")
					if get_user_input_char():match("^y") then
						vim.fn.system({ "trash", vim.fn.fnameescape(path) })
						require("neo-tree.sources.manager").refresh(state.name)
					end
					vim.api.nvim_command("normal :esc<CR>")
				end,
			},
		},
		event_handlers = {
			{
				event = "neo_tree_buffer_enter",
				handler = function(arg)
					vim.cmd [[
						setlocal relativenumber
						setlocal nu
					]]
				end,
			}
		}
	},
	keys = {
		{ "<C-n>", "<cmd>Neotree toggle<CR>", desc = "Toggle Neotree" }
	}
}
