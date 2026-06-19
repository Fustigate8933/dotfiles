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

			-- code cell navigation keymaps for markdown / .ipynb (jupytext-converted) buffers.
			-- We don't go through nvim-treesitter.textobjects.move because legacy nvim-treesitter
			-- (master branch) is incompatible with Neovim 0.11+: query:iter_matches({all=false})
			-- now always returns lists of nodes, so its filter rejects every match and ]b / [b
			-- silently no-op. Use vim.treesitter directly instead.
			local function find_codechunks(bufnr)
				local lang = "markdown"
				local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
				if not ok_parser or not parser then return {} end
				local trees = parser:parse()
				if not trees or not trees[1] then return {} end
				local root = trees[1]:root()
				local query = vim.treesitter.query.get(lang, "textobjects")
				if not query then return {} end
				local target_id
				for id, name in ipairs(query.captures) do
					if name == "codechunk.outer" then target_id = id end
				end
				if not target_id then return {} end
				local ranges = {}
				for id, node in query:iter_captures(root, bufnr) do
					if id == target_id then
						local sr, sc = node:start()
						table.insert(ranges, { sr, sc })
					end
				end
				table.sort(ranges, function(a, b)
					if a[1] ~= b[1] then return a[1] < b[1] end
					return a[2] < b[2]
				end)
				return ranges
			end

			local function goto_codechunk(direction)
				local ranges = find_codechunks(0)
				if #ranges == 0 then return end
				local cr, cc = unpack(vim.api.nvim_win_get_cursor(0))
				cr = cr - 1 -- 0-indexed
				local target
				if direction == "next" then
					for _, r in ipairs(ranges) do
						if r[1] > cr or (r[1] == cr and r[2] > cc) then
							target = r; break
						end
					end
				else
					for i = #ranges, 1, -1 do
						local r = ranges[i]
						if r[1] < cr or (r[1] == cr and r[2] < cc) then
							target = r; break
						end
					end
				end
				if not target then return end
				vim.cmd("normal! m'") -- set jump for `` and Ctrl-O
				vim.api.nvim_win_set_cursor(0, { target[1] + 1, target[2] })
			end

			local function select_codechunk(part)
				local lang = "markdown"
				local ok_parser, parser = pcall(vim.treesitter.get_parser, 0, lang)
				if not ok_parser or not parser then return end
				local trees = parser:parse()
				if not trees or not trees[1] then return end
				local root = trees[1]:root()
				local query = vim.treesitter.query.get(lang, "textobjects")
				if not query then return end
				local target_name = part == "inner" and "codechunk.inner" or "codechunk.outer"
				local target_id
				for id, name in ipairs(query.captures) do
					if name == target_name then target_id = id end
				end
				if not target_id then return end
				local cr, cc = unpack(vim.api.nvim_win_get_cursor(0))
				cr = cr - 1
				local best
				for id, node in query:iter_captures(root, 0) do
					if id == target_id then
						local sr, sc, er, ec = node:range()
						-- end is exclusive; treat (er, 0) as "up to line er-1 inclusive"
						local last_row = (ec == 0) and (er - 1) or er
						local in_range = sr <= cr and cr <= last_row
						if in_range then best = { sr, last_row } end
					end
				end
				if not best then return end
				local mode = vim.api.nvim_get_mode().mode
				if mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode == "\22" then
					vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
				end
				vim.api.nvim_win_set_cursor(0, { best[1] + 1, 0 })
				vim.cmd("normal! V")
				vim.api.nvim_win_set_cursor(0, { best[2] + 1, 0 })
			end

			local set_codechunk_maps = function(bufnr)
				local opts = { buffer = bufnr }
				vim.keymap.set("n", "[b", function() goto_codechunk("prev") end,
					vim.tbl_extend("force", opts, { desc = "previous code block" }))
				vim.keymap.set("n", "]b", function() goto_codechunk("next") end,
					vim.tbl_extend("force", opts, { desc = "next code block" }))
				vim.keymap.set("x", "ib", function() select_codechunk("inner") end,
					vim.tbl_extend("force", opts, { desc = "in block" }))
				vim.keymap.set("x", "ab", function() select_codechunk("outer") end,
					vim.tbl_extend("force", opts, { desc = "around block" }))
				-- swap still depends on legacy nvim-treesitter; leave it unbound rather than
				-- silently broken. Re-add when migrating to nvim-treesitter `main`.
			end
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "markdown" },
				callback = function(ev) set_codechunk_maps(ev.buf) end,
			})
			-- molten was lazy-loaded by the current markdown buffer, so the FileType
			-- autocmd missed it; apply maps to the current buffer too.
			if vim.bo.filetype == "markdown" then
				set_codechunk_maps(0)
			end

			local imb = function(e) -- init molten buffer
				vim.schedule(function()
					local python_host = require("vim.provider.python").detect_by_module("neovim")
					if not python_host then
						return
					end

					local kernels = {}
					local ok_kernels, available_kernels = pcall(vim.fn.MoltenAvailableKernels)
					if ok_kernels and type(available_kernels) == "table" then
						kernels = available_kernels
					end

					local try_kernel_name = function()
						local f = io.open(e.file, "r")
						if not f then
							return nil
						end
						local ok_read, content = pcall(function()
							return f:read("a")
						end)
						f:close()
						if not ok_read or not content then
							return nil
						end
						local metadata = vim.json.decode(content)["metadata"]
						return metadata and metadata.kernelspec and metadata.kernelspec.name or nil
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
						pcall(vim.cmd, ("MoltenInit %s"):format(kernel_name))
					end
					pcall(vim.cmd, "MoltenImportOutput")
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
					-- If python3 host isn't available, do NOT touch molten.status.
					-- Reading molten.status.initialized() forces the FuncUndefined
					-- chain that loads the Python rplugin host via g:python3_host_prog,
					-- which crashes with E475 when the host can't start.
					-- Phase 1 pinned g:python3_host_prog, but this guard keeps saves
					-- safe even on machines where the pin couldn't apply.
					if vim.fn.has("python3") ~= 1 then
						return
					end
					local ok, status = pcall(function()
						return require("molten.status").initialized()
					end)
					if ok and status == "Molten" then
						pcall(vim.cmd, "MoltenExportOutput!")
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

			-- Auto-activate Quarto's code runner for .ipynb buffers (which jupytext
			-- has converted in-place to a markdown buffer). Without this,
			-- pressing <localleader>rc errors with "[Quarto] code runner isn't
			-- initialized for this buffer". Idempotent per buffer via b:quarto_is_active.
			local quarto_ipynb_grp = vim.api.nvim_create_augroup("QuartoIpynbActivate", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				group = quarto_ipynb_grp,
				pattern = { "*.ipynb" },
				callback = function(ev)
					if vim.b[ev.buf].quarto_is_active then
						return
					end
					local ok, q = pcall(require, "quarto")
					if not ok then
						return
					end
					local activate_ok = pcall(q.activate)
					if activate_ok then
						vim.b[ev.buf].quarto_is_active = true
					end
				end,
			})
			-- If the user opened nvim with `nvim foo.ipynb`, the BufEnter for the
			-- current buffer fired BEFORE this autocmd was registered. Catch it.
			if vim.fn.expand("%:e") == "ipynb" and not vim.b.quarto_is_active then
				local ok, q = pcall(require, "quarto")
				if ok and pcall(q.activate) then
					vim.b.quarto_is_active = true
				end
			end
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
