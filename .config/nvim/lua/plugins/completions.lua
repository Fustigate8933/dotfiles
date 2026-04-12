return {
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		}, },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({
						cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				panel = {
					enabled = true,
					auto_refresh = false,
					keymap = {
						jump_prev = "[[",
						jump_next = "]]",
						accept = "<CR>",
						refresh = "gr",
						open = "<M-CR>"
					},
					layout = {
						position = "bottom", -- | top | left | right | bottom |
						ratio = 0.4
					},
				},
				suggestion = {
					enabled = true, -- disable suggestions by default
					auto_trigger = false,
					keymap = {
						accept = "<C-j>"
					}
				},
			})
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken",
		opts = {},
		lazy = false,
		keys = {
			{ "<leader>zc", "<cmd>CopilotChat<cr>", desc = "Copilot Chat", mode="n" },
			{ "<leader>ze", "<cmd>CopilotChatExplain<cr>", desc = "Copilot Chat Explain", mode="v" },
			{ "<leader>zo", "<cmd>CopilotChatOptimize<cr>", desc = "Copilot Chat Optimize", mode="v" },
			{ "<leader>zt", "<cmd>CopilotChatTests<cr>", desc = "Copilot Chat Tests", mode="v" },
			{ "<leader>zr", "<cmd>CopilotChatReview<cr>", desc = "Copilot Chat Review", mode="v" },
			{ "<leader>zf", "<cmd>CopilotChatFix<cr>", desc = "Copilot Chat Fix", mode="v" },
			{ "<leader>zd", "<cmd>CopilotChatDocs<cr>", desc = "Copilot Chat Docs", mode="v" },
			{ "<leader>zm", "<cmd>CopilotChatCommit<cr>", desc = "Copilot Chat Commit", mode="v" },
			{ "<leader>zm", "<cmd>CopilotChatCommit<cr>", desc = "Copilot Chat Commit", mode="n" },
		},
	},
}
