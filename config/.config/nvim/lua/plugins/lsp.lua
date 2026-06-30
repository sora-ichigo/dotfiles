return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")

      opts.servers = opts.servers or {}
      opts.servers.denols = {
        root_dir = util.root_pattern("deno.json", "deno.jsonc"),
      }
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        root_dir = util.root_pattern("package.json", "tsconfig.json"),
        single_file_support = false,
      })
    end,
  },
}
