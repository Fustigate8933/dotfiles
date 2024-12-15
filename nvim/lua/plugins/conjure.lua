vim.g.maplocalleader = "\\"

return {
	{
		"Olical/conjure",
		ft = {"racket"},
		lazy = true,
		init = function()
			vim.g["conjure#client#racket#command"] = "racket"
			vim.g["conjure#client#racket#type"] = "socket"
			vim.g["conjure#mapping#prefix"] = "\\"
			-- vim.keymap.set("n", "<maplocalleader>r", ":ConjureEval<CR>", { desc = "run conjure", silent = true })
			vim.keymap.set("n", "<localleader>ob", "<C-w>v<C-w>l:ConjureLogBuf<CR><C-w>h", {desc = "open conjure buffer"})
			vim.keymap.set("n", "<localleader>rs", "<localleader>cS<localleader>cs", {desc = "restart REPL"})
		end,
		dependencies = {"PaterJason/cmp-conjure", "wlangstroth/vim-racket"}
	},
	{
		"PaterJason/cmp-conjure",
		lazy = true,
		config = function()
			local cmp = require("cmp")
			local config = cmp.get_config()
			table.insert(config.sources, {name = "conjure"})
		end,
	},
	{
		"wlangstroth/vim-racket",
		lazy = true,
	}
}
