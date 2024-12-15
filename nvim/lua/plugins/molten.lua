return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		config = function()
			-- these are examples, not defaults. Please see the readme

			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 50
			vim.g.molten_virt_text_max_lines = 10
			vim.g.localleader = "\\"

			vim.g.molten_auto_open_output = false
			vim.g.molten_output_virt_lines = false
			vim.g.molten_wrap_output = true
			-- vim.g.molten_virt_text_output = true
			-- vim.g.molten_auto_open_output = false
			vim.g.molten_cover_empty_lines = true
			vim.g.molten_output_show_exec_time = true

			-- vim.g.molten_wrap_output = true
			-- vim.g.molten_virt_text_output = false
			-- vim.g.molten_auto_open_output = true
			-- vim.g.molten_cover_empty_lines = true
			-- vim.g.molten_output_win_hide_on_leave = true
			vim.api.nvim_set_hl(0, "MoltenCell", { bg = "NONE" })

			vim.keymap.set(
				"n",
				"<localleader>e",
				":MoltenEvaluateOperator<CR>",
				{ desc = "evaluate operator", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>os",
				":noautocmd MoltenEnterOutput<CR>",
				{ desc = "enter output window", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>d",
				":noautocmd MoltenShowOutput<CR>",
				{ desc = "toggle output window", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>rr",
				":MoltenReevaluateCell<CR>",
				{ desc = "re-eval cell", silent = true }
			)
			vim.keymap.set(
				"v",
				"<localleader>r",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "execute visual selection", silent = true }
			)
			vim.keymap.set(
				"n",
				"<localleader>oh",
				":MoltenHideOutput<CR>",
				{ desc = "close output window", silent = true }
			)
			vim.keymap.set("n", "<localleader>md", ":MoltenDelete<CR>", { desc = "delete Molten cell", silent = true })

			-- if you work with html outputs:
			vim.keymap.set(
				"n",
				"<localleader>mx",
				":MoltenOpenInBrowser<CR>",
				{ desc = "open output in browser", silent = true }
			)

			vim.keymap.set("n", "<localleader>so", ":MoltenShowOutput<CR>", { desc = "open output", silent = true })

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
	},
	{
		-- see the image.nvim readme for more information about configuring this plugin
		"3rd/image.nvim",
		opts = {
			backend = "kitty", -- whatever backend you would like to use
			max_width = 100,
			max_height = 20,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},
}
