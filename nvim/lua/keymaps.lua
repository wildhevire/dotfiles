-- Leader key
vim.g.mapleader = " "
vim.keymap.set("n", "Q","<nop>")
local map = vim.keymap.set
function map_v(mapping, op, misc)
   map('v', mapping, op, misc)
end
function map_n(mapping, op, misc)
   map('n', mapping, op, misc)
end

-- Telescope
local builtin = require("telescope.builtin");
map_n('<leader>ff', builtin.find_files,{desc = "Find file"})
map_n("<leader>fw", builtin.live_grep, {desc = "Find symbol"})
map_n("<leader>fb", builtin.buffers, {desc = "Find symbol on opened buffer"})
map_n("<leader>fh", builtin.help_tags, {desc = "Find help"})


-- Indenting
map_v('<', '<gv', {})
map_v(">", ">gv", {})

-- Nvim-tree (File tree)

map_n("<C-n>", "<cmd> NvimTreeToggle <CR>", {desc = "Toggle file tree"})
map_n("<leader>e", "<cmd> NvimTreeFocus <CR>", {
    desc = "Toggle focus tree",
    noremap = true,
    silent = true
}) 

-- Window Movement
map_n("<C-h>", "<C-w>h", { desc = "Move focus window to left"})
map_n("<C-l>", "<C-w>l", { desc = "Move focus window to right"})
map_n("<C-j>", "<C-w>j", { })
map_n("<C-k>", "<C-w>k", { })

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
map_n("<leader>rn", ToogleLineNumber, { desc= "Toogle Line numbering" })
