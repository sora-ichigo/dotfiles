local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("i", "jj", "<ESC>", opts)
keymap("i", '"',  '""<LEFT>', opts)
keymap("i", "'",  "''<LEFT>", opts)
keymap("i", "`",  "``<LEFT>", opts)

keymap("i", "{",  "{}<LEFT>", opts)
keymap("i", "(",  "()<LEFT>", opts)
keymap("i", "[",  "[]<LEFT>", opts)
keymap("i", "<",  "<><LEFT>", opts)
keymap("i", "<C-k>",  "<Up>", opts)
keymap("i", "<C-j>",  "<Down>", opts)

keymap("i", "<C-h>",  "<Left>", opts)
keymap("i", "<C-l>",  "<Right>", opts)

keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("n", "mm", "<C-w>w", opts)
keymap("n", "m", "<C-w>", opts)
