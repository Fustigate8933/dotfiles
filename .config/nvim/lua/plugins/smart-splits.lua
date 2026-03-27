return {
	"mrjones2014/smart-splits.nvim",
	keys = {
		{ "<C-Left>", function() require("smart-splits").resize_left() end },
		{ "<C-Down>", function() require("smart-splits").resize_down() end },
		{ "<C-Up>", function() require("smart-splits").resize_up() end },
		{ "<C-Right>", function() require("smart-splits").resize_right() end },
	}
}
