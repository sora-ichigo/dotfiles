local options = {
	encoding = "utf-8",
	fileencoding = "utf-8",
  number = true,
  cursorline = true,
  hlsearch = true,
  incsearch = true,
  wildmenu = true,
  smartindent = true,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true,
  smarttab = true,
  laststatus = 2,
  swapfile = false,
}

for k, v in pairs(options) do
	vim.opt[k] = v
end
