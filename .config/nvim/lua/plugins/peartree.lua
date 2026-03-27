return {
	"tmsvg/pear-tree",
	init = function()
		-- don't need to call setup() since pear-tree is a vimscript plugin so the plugin files are automatically loaded
		vim.g.pear_tree_repeatable_expand = 0
	end
}
