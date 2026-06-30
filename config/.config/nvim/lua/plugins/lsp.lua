return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local deno_markers = { "deno.json", "deno.jsonc" }
      local node_markers = { "package.json", "tsconfig.json" }

      opts.servers = opts.servers or {}
      opts.servers.denols = {
        root_dir = function(bufnr, on_dir)
          local root = vim.fs.root(bufnr, deno_markers)
          if root then
            on_dir(root)
          end
        end,
      }
      opts.servers.vtsls = vim.tbl_deep_extend("force", opts.servers.vtsls or {}, {
        root_dir = function(bufnr, on_dir)
          if vim.fs.root(bufnr, deno_markers) then
            return
          end
          local root = vim.fs.root(bufnr, node_markers)
          if root then
            on_dir(root)
          end
        end,
        single_file_support = false,
      })
    end,
  },
}
