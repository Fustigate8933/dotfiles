return {
    "kawre/leetcode.nvim",
    build = "<cmd>TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
        "ibhagwan/fzf-lua",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
    },
    opts = {
        lang = "python3",
		injector = {
			["python3"] = { before = true }
		},
		image_support = false,
    },
}
