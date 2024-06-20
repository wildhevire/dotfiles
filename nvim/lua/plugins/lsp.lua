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
        "Hoffs/omnisharp-extended-lsp.nvim"
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspConfig = require("lspconfig")
            local opts = { noremap = true, silent = true }
            local keymap = vim.keymap
            local on_attach = function(_, bufnr)
                opts.buffer = bufnr

                opts.desc = "Show LSP references"
                keymap.set("n", "<leader>gR", "<cmd>Telescope lsp_references<CR>", opts)

                opts.desc = "Go to declaration"
                keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)

                opts.desc = "Show LSP definitions"
                keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts)

                opts.desc = "Show LSP implementations"
                keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts)

                opts.desc = "Show LSP type definitions"
                keymap.set("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

                opts.desc = "See available code actions"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

                opts.desc = "Smart rename"
                keymap.set("n", "<C-r>", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                opts.desc = "Go to previous error"
                keymap.set("n", "[e", function()
                    vim.diagnostic.goto_prev({
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end, opts)

                opts.desc = "Go to next error"
                keymap.set("n", "]e", function()
                    vim.diagnostic.goto_next({
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end, opts)

                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts)

                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
            end

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            lspConfig.lua_ls.setup({
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = true
                end
            })
            -- C/C++ clangd --
            lspConfig.clangd.setup {
                capabilities = capabilities,
                on_attach = on_attach,
            }
            -- Godot GDScrits --
            local gdscript_config = {
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {},
            }
            if vim.fn.has('win32') == 1 then
                gdscript_config['cmd'] = { 'ncat', 'localhost', os.getenv('GDScript_Port') or '6005' }
            end
            lspConfig.gdscript.setup(gdscript_config)

            lspConfig.omnisharp.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                cmd = { vim.fn.stdpath("data") .. "/mason/packages/omnisharp/omnisharp" },
                handlers = {
                    ["textDocument/definition"] = require("omnisharp_extended").handler,
                    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
                    ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
                },
                enable_editorconfig_support = true,
                enable_ms_build_load_projects_on_demand = false,
                enable_roslyn_analyzers = true,
                organize_imports_on_format = true,
                enable_import_completion = true,
                sdk_include_prereleases = true,
                analyze_open_documents_only = true,
            })
        end
    },
    {
        'Civitasv/cmake-tools.nvim',
        config = function()
            local osys = require("cmake-tools.osys")
            require("cmake-tools").setup {
                cmake_command = "cmake",                                          -- this is used to specify cmake command path
                ctest_command = "ctest",                                          -- this is used to specify ctest command path
                cmake_regenerate_on_save = true,                                  -- auto generate when save CMakeLists.txt
                cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" }, -- this will be passed when invoke `CMakeGenerate`
                cmake_build_options = {},                                         -- this will be passed when invoke `CMakeBuild`
                -- support macro expansion:
                --       ${kit}
                --       ${kitGenerator}
                --       ${variant:xx}
                cmake_build_directory = function()
                    if osys.iswin32 then
                        return "out\\${variant:buildType}"
                    end
                    return "out/${variant:buildType}"
                end,                                         -- this is used to specify generate directory for cmake, allows macro expansion, can be a string or a function returning the string, relative to cwd.
                cmake_soft_link_compile_commands = true,     -- this will automatically make a soft link from compile commands file to project root dir
                cmake_compile_commands_from_lsp = false,     -- this will automatically set compile commands file location using lsp, to use it, please set `cmake_soft_link_compile_commands` to false
                cmake_kits_path = nil,                       -- this is used to specify global cmake kits path, see CMakeKits for detailed usage
                cmake_variants_message = {
                    short = { show = true },                 -- whether to show short message
                    long = { show = true, max_length = 40 }, -- whether to show long message
                },
                cmake_dap_configuration = {                  -- debug settings for cmake
                    name = "cpp",
                    type = "codelldb",
                    request = "launch",
                    stopOnEntry = false,
                    runInTerminal = true,
                    console = "integratedTerminal",
                },
                cmake_executor = {                          -- executor to use
                    name = "quickfix",                      -- name of the executor
                    opts = {},                              -- the options the executor will get, possible values depend on the executor type. See `default_opts` for possible values.
                    default_opts = {                        -- a list of default and possible values for executors
                        quickfix = {
                            show = "always",                -- "always", "only_on_error"
                            position = "belowright",        -- "vertical", "horizontal", "leftabove", "aboveleft", "rightbelow", "belowright", "topleft", "botright", use `:h vertical` for example to see help on them
                            size = 10,
                            encoding = "utf-8",             -- if encoding is not "utf-8", it will be converted to "utf-8" using `vim.fn.iconv`
                            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
                        },
                        toggleterm = {
                            direction = "float",   -- 'vertical' | 'horizontal' | 'tab' | 'float'
                            close_on_exit = false, -- whether close the terminal when exit
                            auto_scroll = true,    -- whether auto scroll to the bottom
                            singleton = true,      -- single instance, autocloses the opened one, if present
                        },
                        overseer = {
                            new_task_opts = {
                                strategy = {
                                    "toggleterm",
                                    direction = "horizontal",
                                    autos_croll = true,
                                    quit_on_exit = "success"
                                }
                            }, -- options to pass into the `overseer.new_task` command
                            on_new_task = function(task)
                                require("overseer").open(
                                    { enter = false, direction = "right" }
                                )
                            end, -- a function that gets overseer.Task when it is created, before calling `task:start`
                        },
                        terminal = {
                            name = "Main Terminal",
                            prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
                            split_direction = "horizontal", -- "horizontal", "vertical"
                            split_size = 11,

                            -- Window handling
                            single_terminal_per_instance = true,  -- Single viewport, multiple windows
                            single_terminal_per_tab = true,       -- Single viewport per tab
                            keep_terminal_static_location = true, -- Static location of the viewport if avialable

                            -- Running Tasks
                            start_insert = false,       -- If you want to enter terminal with :startinsert upon using :CMakeRun
                            focus = false,              -- Focus on terminal when cmake task is launched.
                            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
                        },                              -- terminal executor uses the values in cmake_terminal
                    },
                },
                cmake_runner = {                     -- runner to use
                    name = "terminal",               -- name of the runner
                    opts = {},                       -- the options the runner will get, possible values depend on the runner type. See `default_opts` for possible values.
                    default_opts = {                 -- a list of default and possible values for runners
                        quickfix = {
                            show = "always",         -- "always", "only_on_error"
                            position = "belowright", -- "bottom", "top"
                            size = 10,
                            encoding = "utf-8",
                            auto_close_when_success = true, -- typically, you can use it with the "always" option; it will auto-close the quickfix buffer if the execution is successful.
                        },
                        toggleterm = {
                            direction = "float",   -- 'vertical' | 'horizontal' | 'tab' | 'float'
                            close_on_exit = false, -- whether close the terminal when exit
                            auto_scroll = true,    -- whether auto scroll to the bottom
                            singleton = true,      -- single instance, autocloses the opened one, if present
                        },
                        overseer = {
                            new_task_opts = {
                                strategy = {
                                    "toggleterm",
                                    direction = "horizontal",
                                    autos_croll = true,
                                    quit_on_exit = "success"
                                }
                            },   -- options to pass into the `overseer.new_task` command
                            on_new_task = function(task)
                            end, -- a function that gets overseer.Task when it is created, before calling `task:start`
                        },
                        terminal = {
                            name = "Main Terminal",
                            prefix_name = "[CMakeTools]: ", -- This must be included and must be unique, otherwise the terminals will not work. Do not use a simple spacebar " ", or any generic name
                            split_direction = "horizontal", -- "horizontal", "vertical"
                            split_size = 11,

                            -- Window handling
                            single_terminal_per_instance = true,  -- Single viewport, multiple windows
                            single_terminal_per_tab = true,       -- Single viewport per tab
                            keep_terminal_static_location = true, -- Static location of the viewport if avialable

                            -- Running Tasks
                            start_insert = false,       -- If you want to enter terminal with :startinsert upon using :CMakeRun
                            focus = false,              -- Focus on terminal when cmake task is launched.
                            do_not_add_newline = false, -- Do not hit enter on the command inserted when using :CMakeRun, allowing a chance to review or modify the command before hitting enter.
                        },
                    },
                },
                cmake_notifications = {
                    runner = { enabled = true },
                    executor = { enabled = true },
                    spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }, -- icons used for progress display
                    refresh_rate_ms = 100, -- how often to iterate icons
                },
                cmake_virtual_text_support = true, -- Show the target related to current file using virtual text (at right corner)
            }
        end
    }
}
