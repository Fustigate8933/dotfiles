return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {
			ensure_installed = { "lua_ls", "pyright", "ts_ls", "tailwindcss", "vue_ls", "eslint", "ruby_lsp", "qmlls" },
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = {},
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
		},
		config = function(_, opts)
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/"

			vim.lsp.config.lua_ls = vim.tbl_extend("force", {
				cmd = { mason_bin .. "lua-language-server" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					"stylua.toml",
					"selene.toml",
					"selene.yml",
					".git",
				},
				filetypes = { "lua" },
				capabilities = capabilities,
			}, opts or {})

			vim.lsp.config.pyright = {
				cmd = { "pyright-langserver", "--stdio" },
				root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
				filetypes = { "python" },
				capabilities = capabilities,
				settings = {
					python = {
						pythonPath = vim.fn.getcwd() .. "/.venv/bin/python", 
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticSeverityOverrides = {
								reportUnusedExpression = "none",
							},
						},					},
				},
			}

			vim.lsp.config.tailwindcss = {
				cmd = { "tailwindcss-language-server", "--stdio" },
				root_markers = {
					"tailwind.config.js",
					"tailwind.config.cjs",
					"tailwind.config.mjs",
					"tailwind.config.ts",
					".git",
				},
				filetypes = {
					"css",
					"scss",
					"sass",
					"html",
					"javascript",
					"javascriptreact",
					"typescript",
					"typescriptreact",
					"vue",
					"svelte",
				},
				capabilities = capabilities,
			}

			vim.lsp.config.eslint = {
				cmd = { "vscode-eslint-language-server", "--stdio" },
				root_markers = {
					".eslintrc",
					".eslintrc.js",
					".eslintrc.cjs",
					".eslintrc.yaml",
					".eslintrc.yml",
					".eslintrc.json",
					"eslint.config.js",
					"package.json",
					".git",
				},
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				capabilities = capabilities,
			}

			vim.lsp.config.clangd = {
				cmd = { "/usr/bin/clangd" },
				root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
				capabilities = capabilities,
				init_options = {
					fallbackFlags = {
						"-std=c++20",
					},
				},
			}

			vim.lsp.config.ruby_lsp = {
				cmd = { "ruby-lsp" },
				root_markers = { "Gemfile", ".git" },
				filetypes = { "ruby", "eruby" },
				capabilities = capabilities,
			}

			vim.lsp.config.ts_ls = {
				cmd = { "typescript-language-server", "--stdio" },
				root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				capabilities = capabilities,
				init_options = {
					plugins = {
						{
							name = "@vue/typescript-plugin",
							location = "/home/fustigate/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server",
							languages = { "vue" },
						},
					},
				},
			}

			vim.lsp.config.rust_analyzer = {
				cmd = { "rust-analyzer" },
				root_markers = { "Cargo.toml", ".git" },
				filetypes = { "rust" },
				capabilities = capabilities,
			}

			vim.lsp.config.qmlls = {
				cmd = { "/usr/lib/qt6/bin/qmlls" },
				root_markers = { ".git", "*.qmlproject" },
				filetypes = { "qml", "qmljs" },
				capabilities = capabilities,
				settings = {
					qml = {
						importPaths = {
							"/usr/lib/qt6/qml",
						},
					},
				},
			}

			vim.lsp.enable({ "lua_ls", "pyright", "tailwindcss", "eslint", "clangd", "ruby_lsp", "ts_ls", "qmlls" })
		end,
		keys = {
			{
				"K",
				function()
					vim.lsp.buf.hover()
				end,
				desc = "Display hover information",
			},
			{
				"gd",
				function()
					vim.lsp.buf.definition()
				end,
				desc = "Go to definition",
			},
			{
				"gD",
				function()
					vim.lsp.buf.declaration()
				end,
				desc = "Go to declaration",
			},
			{
				"<leader>ca",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "Code action",
			},
		},
	},
	{
		"nvimtools/none-ls.nvim", -- this plugin allows you to use tools like linters and formatters as if they were LSPs
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
		},
		lazy = false,
		config = function()
			local null_ls = require("null-ls")
			local eslint_diagnostics = require("none-ls.diagnostics.eslint_d")
			local eslint_formatting = require("none-ls.formatting.eslint_d")
			null_ls.setup({
				sources = {
					eslint_diagnostics,
					eslint_formatting,
					-- null_ls.builtins.diagnostics.eslint, -- eslint
					null_ls.builtins.formatting.stylua, -- stylua is a formatter for lua files
					null_ls.builtins.formatting.isort, -- formatter for python, sorts imports alphabetically
					null_ls.builtins.formatting.black, -- general python formatter
					null_ls.builtins.diagnostics.pylint.with({
						extra_args = { "--disable=too-many-nested-blocks", "--disable=line-too-long" },
					}), -- python linter
					null_ls.builtins.formatting.prettier,
					null_ls.builtins.formatting.rubocop,
				},
			})

			vim.diagnostic.config({
				virtual_text = true, -- enable virtual text (disabled by default)
			})
		end,
		keys = {
			{
				"<leader>gf",
				function()
					vim.lsp.buf.format()
				end,
				desc = "Format code",
			},
			{ "<leader>e", "<cmd>lua vim.diagnostic.open_float()<CR>" },
		},
	},
}
