-- Readme
--
--
-- Keymap for code completion located in lua/plugins/completions.lua
-- This is because nvim-cmp require mapping declared on setup process
-- Keymap for code commenting also located in lua/plugin/comment.lua
-- Key map for LSP also located lua/plugin/lsp
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
map_n("<leader>fn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
end, {})

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

map_n("<C-Left>", "<C-w>h", {})
map_n("<C-Right>", "<C-w>l", {})
map_n("<C-Down>", "<C-w>j", {})
map_n("<C-Up>", "<C-w>k", {})

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
vim.cmd("set number relativenumber")
map_n("<leader>rn", ToogleLineNumber, { desc = "Toogle Line numbering" })


-- bufferline
map_n("<TAB>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
map_n("<S-TAB>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
map_n("<leader>xy", ":bdelete!<CR>", { noremap = true, silent = true })


-- Formatting
map_n("<leader>fm", vim.lsp.buf.format, { desc = "Format current buffer" })

vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, lspOpts)
vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, lspOpts)
vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, lspOpts)
