-- if molten isn't runnnig in .ipynb files try running :UpdateRemotePlugins
return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		dependencies = {
			"3rd/image.nvim",
			"GCBallesteros/jupytext.nvim"
		},
		ft = { "markdown" },
		build = "<cmd>UpdateRemotePlugins",
		config = function()
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 50
			vim.g.molten_virt_text_max_lines = 10
			vim.g.localleader = "\\"
			vim.g.molten_auto_open_output = false
			vim.g.molten_output_virt_lines = false
			vim.g.molten_wrap_output = true
			vim.g.molten_cover_empty_lines = true
			vim.g.molten_output_show_exec_time = true
			-- vim.g.molten_virt_text_output = true
			-- vim.g.molten_auto_open_output = false
			-- vim.g.molten_wrap_output = true
			-- vim.g.molten_virt_text_output = false
			-- vim.g.molten_auto_open_output = true
			-- vim.g.molten_cover_empty_lines = true
			-- vim.g.molten_output_win_hide_on_leave = true
			vim.api.nvim_set_hl(0, "MoltenCell", { bg = "NONE" })

			local imb = function(e) -- init molten buffer
				vim.schedule(function()
					local kernels = vim.fn.MoltenAvailableKernels()
					local try_kernel_name = function()
						local metadata = vim.json.decode(io.open(e.file, "r"):read("a"))["metadata"]
						return metadata.kernelspec.name
					end
					local ok, kernel_name = pcall(try_kernel_name)
					if not ok or not vim.tbl_contains(kernels, kernel_name) then
						kernel_name = nil
						local venv = os.getenv("VIRTUAL_ENV")
						if venv ~= nil then
							kernel_name = string.match(venv, "/.+/(.+)")
						end
					end
					if kernel_name ~= nil and vim.tbl_contains(kernels, kernel_name) then
						vim.cmd(("MoltenInit %s"):format(kernel_name))
					end
					vim.cmd("MoltenImportOutput")
				end)
			end

			-- automatically import output chunks from a jupyter notebook
			vim.api.nvim_create_autocmd("BufAdd", {
				pattern = { "*.ipynb" },
				callback = imb,
			})

			-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						imb(e)
					end
				end,
			})

			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					if require("molten.status").initialized() == "Molten" then
						vim.cmd("MoltenExportOutput!")
					end
				end,
			})

			vim.api.nvim_set_hl(0, "MoltenVirtualText", { fg = "#7ab2bd" })
		end,
		keys = {
			{ "<localleader>e",  "<cmd>MoltenEvaluateOperator<CR>",      desc = "evaluate operator" },
			{ "<localleader>os", "<cmd>noautocmd MoltenEnterOutput<CR>", desc = "enter output window" },
			{ "<localleader>d",  "<cmd>noautocmd MoltenShowOutput<CR>",  desc = "toggle output window" },
			{ "<localleader>rr", "<cmd>MoltenReevaluateCell<CR>",        desc = "re-eval cell" },
			{ "<localleader>r",  "<cmd><C-u>MoltenEvaluateVisual<CR>gv", desc = "execute visual selection", mode = "v" },
			{ "<localleader>oh", "<cmd>MoltenHideOutput<CR>",            desc = "close output window" },
			{ "<localleader>md", "<cmd>MoltenDelete<CR>",                desc = "delete Molten cell" },
			{ "<localleader>mx", "<cmd>MoltenOpenInBrowser<CR>",         desc = "open output in browser" },
			{ "<localleader>so", "<cmd>MoltenShowOutput<CR>",            desc = "open output" },
		}
	},
	{
		"3rd/image.nvim",
		ft = { "markdown" },
		opts = {
			backend = "kitty",
			max_width = 100,
			max_height = 20,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			"jmbuhr/otter.nvim",
			"hrsh7th/nvim-cmp",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "quarto", "markdown" },
		config = function()
			require("quarto").activate()
			local otter = require("otter")
			local languages = { "python" }
			local completion = true
			local tsquery = nil
			local diagnostics = true
			otter.activate(languages, completion, diagnostics, tsquery)

			local quarto = require("quarto")
			quarto.setup({
				lspFeatures = {
					enabled = true,
					-- NOTE: put whatever languages you want here:
					languages = { "python" },
					chunks = "all",
					diagnostics = {
						enabled = true,
						triggers = { "BufWritePost" },
					},
					completion = {
						enabled = true,
					},
				},
				codeRunner = {
					enabled = true,
					default_method = "molten",
				},
			})
		end,
		keys = {
			{
				"<localleader>rc",
				function()
					require("quarto.runner").run_cell()
				end,
				desc = "Run cell",
			},
			{
				"<localleader>ra",
				function()
					require("quarto.runner").run_above()
				end,
				desc = "Run cell and above",
			},
			{
				"<localleader>rA",
				function()
					require("quarto.runner").run_all()
				end,
				desc = "Run all cells",
			},
			{
				"<localleader>rl",
				function()
					require("quarto.runner").run_line()
				end,
				desc = "Run line",
			},
			{
				"<localleader>r",
				function()
					require("quarto.runner").run_range()
				end,
				desc = "Run visual range",
				mode = "v",
			},
			{
				"<localleader>RA",
				function()
					require("quarto.runner").run_all(true)
				end,
				desc = "Run all cells of all languages",
			},
			{ "<localleader>nc", "A<cr>```python<cr><cr>```<cr><esc>kki" },
			{ "<leader>mi",      "<cmd>MoltenInit<CR>:lua require('quarto').activate()<CR>" },
		},

	},
	{
		"GCBallesteros/jupytext.nvim",
		config = true,
		ft = { "markdown" },
		init = function()
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
			})
		end,
	}
}
