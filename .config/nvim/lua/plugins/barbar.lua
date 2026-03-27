return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {},
	lazy = false,
	keys = {
		-- M is Alt
		{ "<M-.>", "<Cmd>BufferNext<CR>", desc = "Next buffer" },
		{ "<M-,>", "<Cmd>BufferPrevious<CR>", desc = "Previous buffer" },
		{ "<M-1>", "<Cmd>BufferGoto 1<CR>", desc = "Go to buffer 1" },
		{ "<M-2>", "<Cmd>BufferGoto 2<CR>", desc = "Go to buffer 2" },
		{ "<M-3>", "<Cmd>BufferGoto 3<CR>", desc = "Go to buffer 3" },
		{ "<M-4>", "<Cmd>BufferGoto 4<CR>", desc = "Go to buffer 4" },
		{ "<M-5>", "<Cmd>BufferGoto 5<CR>", desc = "Go to buffer 5" },
		{ "<M-6>", "<Cmd>BufferGoto 6<CR>", desc = "Go to buffer 6" },
		{ "<M-7>", "<Cmd>BufferGoto 7<CR>", desc = "Go to buffer 7" },
		{ "<M-8>", "<Cmd>BufferGoto 8<CR>", desc = "Go to buffer 8" },
		{ "<M-9>", "<Cmd>BufferGoto 9<CR>", desc = "Go to buffer 9" },
		{ "<M-c>", "<Cmd>BufferClose<CR>", desc = "Close buffer" },
	},
}
