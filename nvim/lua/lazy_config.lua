local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")


-- local plugins = {
--     { 
--         "catppuccin/nvim", name = "catppuccin", priority = 1000 
--     },
--     {
--         "nvim-treesitter/nvim-treesitter",
--         build = ":TSUpdate"
--     },
--     {
--     'nvim-telescope/telescope.nvim', tag = '0.1.6',
-- -- or                              , branch = '0.1.x',
--       dependencies = { 'nvim-lua/plenary.nvim' }
--     },
--     {
--         "nvim-tree/nvim-tree.lua",
--         version = "*",
--         lazy = false,
--         dependencies = {
--             "nvim-tree/nvim-web-devicons",
--         },
--         config = function()
--         require("nvim-tree").setup {}
--         end,
--     },
-- }

-- local opts = {}


-- require'nvim-treesitter.configs'.setup {
--   ensure_installed = { 
--       "c", 
--       "lua", 
--       "vim", 
--   },
--   sync_install = false,
--   auto_install = true,
--   ignore_install = { "javascript" },

--   highlight = {
--     enable = true,
--     additional_vim_regex_highlighting = false,
--   },
-- }

-- require('lualine').setup{
--     options = {
--         theme = "onedark"
--     }
-- }