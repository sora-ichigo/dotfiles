local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.g.vscode then
else
  keymap("n", "mm", "<C-w>w", opts)
  keymap("n", "m", "<C-w>", opts)

  keymap('n', 'ff', "<cmd>Telescope find_files hidden=true<cr>", {})
  keymap('n', 'fg', "<cmd>Telescope live_grep hidden=true<cr>", {})
  keymap('n', 'fb', "<cmd>Telescope buffers hidden=true<cr>", {})
  keymap('n', 'fh', "<cmd>Telescope help_tags hidden=true<cr>", {})

  keymap('n', '<C-n>', "<cmd>Fern . -drawer -toggle<cr>", {})

  keymap('n', '<Space>a', "<Plug>(coc-codeaction-selected)", {})

  keymap('n', '<C-y>', "<cmd>ToggleTerm size=30<cr>", {})
  keymap("n", "gl", "<cmd>lua _lazygit_toggle()<CR>", { noremap = true, silent = true })

  keymap('t', '<C-y>', "<C-\\><C-n><cmd>ToggleTerm size=30<cr>", {})

  keymap("i", "<C-k>",  "<Up>", opts)
  keymap("i", "<C-j>",  "<Down>", opts)
  keymap("i", "<C-h>",  "<Left>", opts)
  keymap("i", "<C-l>",  "<Right>", opts)
end

keymap("i", "jj", "<ESC>", opts)
keymap("i", '"', '""<LEFT>', opts)
keymap("i", "'", "''<LEFT>", opts)
keymap("i", "`", "``<LEFT>", opts)

keymap("i", "{", "{}<LEFT>", opts)
keymap("i", "(", "()<LEFT>", opts)
keymap("i", "[", "[]<LEFT>", opts)
keymap("i", "<", "<><LEFT>", opts)
keymap("i", ",", ", ", opts)

keymap("v", "H", "^", opts)
keymap("v", "L", "$", opts)

keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)

