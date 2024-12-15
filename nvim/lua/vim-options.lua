local set = vim.opt
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.incsearch = true
vim.opt.hlsearch = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
-- vim.opt.autochdir = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

vim.cmd [[inoremap <C-BS> <C-w>]]
vim.cmd [[
  autocmd VimEnter * Copilot disable
]]


vim.keymap.set("n", "<C-A>", "ggVG", {})
vim.keymap.set("n", "<leader>e", ":lua vim.diagnostic.open_float()<CR>", {})
vim.keymap.set("i", "<C-\\>", "λ")

vim.keymap.set("v", "<C-c>", '"+y')
