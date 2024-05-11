-- Leader key
vim.g.mapleader = " "
-- Clipboard
vim.opt.clipboard = "unnamedplus"
-- Spaces and tab
vim.o.tabstop = 4
vim.o.expandtab = true
vim.softtabstop = 4
vim.o.shiftwidth = 4

vim.wo.relativenumber =  true
vim.opt.breakindent = true
vim.opt.formatoptions:remove "t"
vim.opt.linebreak = true

-- Incremental search
vim.opt.incsearch = true

-- Use termninal color
vim.opt.termguicolors = true

-- Set Scroll offset 
vim.opt.scrolloff = 10

vim.opt.signcolumn = "yes"
vim.opt.isfname:append "@-@"
vim.opt.updatetime = 50
