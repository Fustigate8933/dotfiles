return {
	"windwp/nvim-ts-autotag",
	ft = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"html",
		"vue",
	},
	config = function()
		require("nvim-ts-autotag").setup()
	end
}
