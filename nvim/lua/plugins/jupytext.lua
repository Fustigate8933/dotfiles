return {
	"GCBallesteros/jupytext.nvim",
	config = true,
	lazy = false,
	init = function()
		require("jupytext").setup({
			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		})
	end,
}
