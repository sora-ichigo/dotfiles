-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>oo", function()
  local path = vim.fn.resolve(vim.fn.expand("%:p"))
  local ok, config = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(vim.fn.expand("~/Library/Application Support/obsidian/obsidian.json")), "\n"))
  end)
  local in_vault = ok and vim.iter(vim.tbl_values(config.vaults or {})):any(function(vault)
    return vim.startswith(path, vault.path .. "/")
  end)
  if not in_vault then
    vim.notify("Obsidian の vault 外のファイルです: " .. path, vim.log.levels.WARN)
    return
  end
  vim.system({ "open", "obsidian://open?path=" .. vim.uri_encode(path, "rfc3986") })
end, { desc = "Open in Obsidian" })
