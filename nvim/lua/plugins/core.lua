return {
    -- Color Scheme
    { 
        "catppuccin/nvim", 
        name = "catppuccin", 
        priority = 1000,
        
    },


    --- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function ()
            require('nvim-treesitter.configs').setup {
                ensure_installed = { 
                    "c", 
                    "lua", 
                    "vim", 
                    "rust"
                },
                sync_install = false,
                ignore_install = { "javascript" },
              
                highlight = {
                  enable = true,
                },
                indent = { enable = true },  
                auto_install = true
              }
        end
    },


    -- Telescope
    {

        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        dependencies = { 
            'nvim-lua/plenary.nvim'
        }
    },


    --Nvim tree
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("nvim-tree").setup {}
        end,
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup{
                options = {
                    theme = "onedark"
                }
            }
        end
    },

    {
        {
            'akinsho/bufferline.nvim', 
            version = "*", 
            dependencies = 'nvim-tree/nvim-web-devicons',
            config = function() 
                require("bufferline").setup{}
            end
        }
    },
 {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            require("telescope").setup {
              extensions = {
                ["ui-select"] = {
                  require("telescope.themes").get_dropdown {}
                }
              }
            }
            require("telescope").load_extension("ui-select")
        end
    },
}



