local vimopt = vim.opt

vim.g.mapleader = " " -- global leader key
vim.g.maplocalleader = "\\"

vimopt.tabstop = 4
vimopt.softtabstop = 4
vimopt.shiftwidth = 4
vimopt.nu = true -- display line numbers
vimopt.relativenumber = true
vimopt.smartindent = true
vimopt.autoindent = true
vimopt.incsearch = true -- incremental search
vimopt.hlsearch = false -- highlight search pattern after search completion
vimopt.termguicolors = true
vimopt.scrolloff = 8
vimopt.undofile = true -- retain undo history even after closing files
vimopt.undodir = vim.fn.stdpath("data") .. "/undodir"
vimopt.splitright = true

vim.cmd [[inoremap <C-BS> <C-w>]]
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set("n", "<C-A>", "ggVG", { desc = "Select all" })
