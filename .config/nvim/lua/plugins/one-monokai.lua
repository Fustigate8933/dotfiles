return {
	"cpea2506/one_monokai.nvim",
	opts = {
		highlights = function () -- highlights expects a function because one_monokai expects a function
			return {
				Comment = { fg = "#969898" }
			}
		end
	}
}

