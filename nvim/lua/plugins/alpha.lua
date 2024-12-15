return {
	"goolord/alpha-nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.startify")

		dashboard.section.header.val = {
			[[          ▀████▀▄▄              ▄█ ]],
			[[            █▀    ▀▀▄▄▄▄▄    ▄▄▀▀█ ]],
			[[    ▄        █          ▀▀▀▀▄  ▄▀  ]],
			[[   ▄▀ ▀▄      ▀▄              ▀▄▀  ]],
			[[  ▄▀    █     █▀   ▄█▀▄      ▄█    ]],
			[[  ▀▄     ▀▄  █     ▀██▀     ██▄█   ]],
			[[   ▀▄    ▄▀ █   ▄██▄   ▄  ▄  ▀▀ █  ]],
			[[    █  ▄▀  █    ▀██▀    ▀▀ ▀▀  ▄▀  ]],
			[[   █   █  █      ▄▄           ▄▀   ]],
		}

		dashboard.opts.layout[1].val = 2
		-- dashboard.opts.opts.margin = 70

		-- Send config to alpha
		alpha.setup(dashboard.config)

		-- Disable folding on alpha buffer
		vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])
	end,
}
