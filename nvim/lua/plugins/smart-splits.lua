return {
	"mrjones2014/smart-splits.nvim",
	config = function()
		vim.keymap.set("n", "<C-Left>", require("smart-splits").resize_left)
		vim.keymap.set("n", "<C-Down>", require("smart-splits").resize_down)
		vim.keymap.set("n", "<C-Up>", require("smart-splits").resize_up)
		vim.keymap.set("n", "<C-Right>", require("smart-splits").resize_right)
	end,
}
