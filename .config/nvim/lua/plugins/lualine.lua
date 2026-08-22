return {
	'nvim-lualine/lualine.nvim',
	opts = {
		options = {
			theme = "auto"
		},
		sections = {
			lualine_c = {
				{ 'filename', path = 3 }
			}
		}
	}
}

