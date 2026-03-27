return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Display buffer Local Keymaps",
		},
	},
	config = function()
		require("which-key").add({
			{ "m", group = "marks" },
			{ "dm", group = "delete mark" },
			{ "dm-", desc = "Delete mark by name" },
			{ "dm<space>", desc = "Delete all marks on line" },
			{ "dm=", desc = "Delete all marks in buffer" },
		})
	end,
}
