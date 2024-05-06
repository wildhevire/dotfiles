-- Leader key
vim.g.mapleader = " "
-- Telescope
local builtin = require("telescope.builtin");
vim.keymap.set('n', '<leader>ff', builtin.find_files,{})
vim.keymap.set("n", "Q","<nop>")

