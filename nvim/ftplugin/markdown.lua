require("quarto").activate()
local otter = require("otter")

vim.keymap.set("n", "<C-Space>", otter.ask_hover, {buffer = 0, noremap=true, silent=true})
vim.keymap.set("n", "gd", otter.ask_definition, {})
