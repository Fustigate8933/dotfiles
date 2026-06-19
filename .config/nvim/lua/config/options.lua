local vimopt = vim.opt

-- Pin the Python3 remote-plugin host so molten / jupytext / any rplugin
-- consumer doesn't fall through Neovim's auto-detect logic. Without this,
-- saving a .ipynb (which fires the molten BufWritePost autocmd) loads
-- the Python rplugin host using `g:python3_host_prog`, which is `v:null`
-- when unset and triggers `E475: 'v:null' is not executable`.
-- The executable() guard keeps the config portable across machines that
-- may not have /usr/bin/python3 (e.g. macOS, NixOS).
if vim.fn.executable("/usr/bin/python3") == 1 then
	vim.g.python3_host_prog = "/usr/bin/python3"
end

vim.g.mapleader = " " -- global leader key
vim.g.maplocalleader = "\\"

vimopt.expandtab = true
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


-- remove trailing whitespaces on save
local TrimWhiteSpaceGrp = vim.api.nvim_create_augroup("TrimWhiteSpaceGrp", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    group = TrimWhiteSpaceGrp,
    pattern = "*",
    callback = function()
        -- Skip buffers we should never substitute on:
        --   - non-modifiable (e.g. :checkhealth, fugitive blob views, help)
        --   - special buftypes (nofile, prompt, terminal, quickfix, acwrite, help)
        -- Without this guard, BufWritePre fires on healthcheck writes and crashes
        -- with `E21: Cannot make changes, 'modifiable' is off`.
        if not vim.bo.modifiable or vim.bo.buftype ~= "" then
            return
        end

        -- Save cursor position to restore later
        local save_cursor = vim.fn.winsaveview()

        vim.cmd([[%s/\s\+$//e]])

        vim.fn.winrestview(save_cursor)
    end,
})
