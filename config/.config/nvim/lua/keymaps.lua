local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("i", "jj", "<ESC>", opts)
keymap("i", '"', '""<LEFT>', opts)
keymap("i", "'", "''<LEFT>", opts)
keymap("i", "`", "``<LEFT>", opts)

keymap("i", "{", "{}<LEFT>", opts)
keymap("i", "(", "()<LEFT>", opts)
keymap("i", "[", "[]<LEFT>", opts)
keymap("i", "<", "<><LEFT>", opts)
keymap("i", ",", ", ", opts)
keymap("i", "<C-k>",  "<Up>", opts)
keymap("i", "<C-j>",  "<Down>", opts)

keymap("i", "<C-h>",  "<Left>", opts)
keymap("i", "<C-l>",  "<Right>", opts)

keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("n", "mm", "<C-w>w", opts)
keymap("n", "m", "<C-w>", opts)
keymap("n", "gl", "gt", opts)
keymap("n", "gh", "gT", opts)

keymap('n', 'ff', "<cmd>Telescope find_files hidden=true<cr>", {})
keymap('n', 'fg', "<cmd>Telescope live_grep hidden=true<cr>", {})
keymap('n', 'fb', "<cmd>Telescope buffers hidden=true<cr>", {})
keymap('n', 'fh', "<cmd>Telescope help_tags hidden=true<cr>", {})

keymap('n', 'nn', "<cmd>Fern . -drawer -toggle<cr>", {})

keymap('n', '<Space>a', "<Plug>(coc-codeaction-selected)", {})
