return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({})
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup {
                ensure_installed = {
                    "clangd",
                    "omnisharp",
                    "rust_analyzer",
                    "lua_ls"
                }
            }
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspConfig = require("lspconfig")
            lspConfig.lua_ls.setup({
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = true
                end
            })
            lspConfig.clangd.setup{}
        end
    }
}
