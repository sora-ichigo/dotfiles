-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>oo", function()
  local path = vim.fn.resolve(vim.fn.expand("%:p"))
  vim.system({ "open", "obsidian://open?path=" .. vim.uri_encode(path, "rfc3986") })
end, { desc = "Open in Obsidian" })
