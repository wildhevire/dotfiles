-- Readme
--
--
-- Keymap for code completion located in lua/plugins/completions.lua
-- This is because nvim-cmp require mapping declared on setup process
--
--
vim.keymap.set("n", "Q", "<nop>")
local map = vim.keymap.set
function map_v(mapping, op, misc)
    map('v', mapping, op, misc)
end

function map_n(mapping, op, misc)
    map('n', mapping, op, misc)
end

-- Telescope
local builtin = require("telescope.builtin");
map_n('<leader>ff', builtin.find_files, { desc = "Find file" })
map_n("<leader>fw", builtin.live_grep, { desc = "Find symbol" })
map_n("<leader>fb", builtin.buffers, { desc = "Find symbol on opened buffer" })
map_n("<leader>fh", builtin.help_tags, { desc = "Find help" })


-- Indenting
map_v('<', '<gv', {})
map_v(">", ">gv", {})

-- Nvim-tree (File tree)

map_n("<C-n>", "<cmd> NvimTreeToggle <CR>", { desc = "Toggle file tree" })
map_n("<leader>e", "<cmd> NvimTreeFocus <CR>", {
    desc = "Toggle focus tree",
    noremap = true,
    silent = true
})

-- Window Movement
map_n("<C-h>", "<C-w>h", { desc = "Move focus window to left" })
map_n("<C-l>", "<C-w>l", { desc = "Move focus window to right" })
map_n("<C-j>", "<C-w>j", {})
map_n("<C-k>", "<C-w>k", {})

-- lineNumber
local useRelativeLineNumber = true
function ToogleLineNumber()
    useRelativeLineNumber = not useRelativeLineNumber
    if useRelativeLineNumber then
        vim.cmd("set nu!")
    else
        vim.cmd("set rnu!")
    end
end

map_n("<leader>rn", ToogleLineNumber, { desc = "Toogle Line numbering" })


-- bufferline
map_n("<TAB>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
map_n("<S-TAB>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
map_n("<leader>xy", ":bdelete!<CR>", { noremap = true, silent = true })

-- LSP
local lspOpts = { noremap = true, silent = true }
map_n("K", vim.lsp.buf.hover, lspOpts)
map_n("gd", vim.lsp.buf.definition, lspOpts)
map_n("gD", vim.lsp.buf.declaration, lspOpts)
map_n("gi", vim.lsp.buf.implementation, lspOpts)
-- Formatting
map_n("<leader>fm", vim.lsp.buf.format, { desc = "Format current buffer" })

-- TODO: Maybe change this because it taken from minimal config
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/test/minimal_init.lua
-- code actions
vim.keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", lspOpts)

vim.keymap.set("n", "<C-p>", vim.diagnostic.goto_prev, lspOpts)
vim.keymap.set("n", "<A-p>", vim.diagnostic.goto_next, lspOpts)
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, lspOpts)

vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, lspOpts)
vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, lspOpts)
vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, lspOpts)
vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, lspOpts)
vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, lspOpts)
vim.keymap.set("n", "gr", vim.lsp.buf.references, lspOpts)
vim.keymap.set("n", "<leader>E", vim.diagnostic.open_float, lspOpts)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, lspOpts)


