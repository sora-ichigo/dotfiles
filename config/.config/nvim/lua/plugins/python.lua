return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
              },
            },
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "mypy" },
      },
      linters = {
        mypy = {
          cmd = function()
            local venv = os.getenv("VIRTUAL_ENV")
            if venv then
              local p = venv .. "/bin/mypy"
              if vim.fn.executable(p) == 1 then
                return p
              end
            end
            local root = vim.fs.root(0, { ".venv" })
            if root then
              local p = root .. "/.venv/bin/mypy"
              if vim.fn.executable(p) == 1 then
                return p
              end
            end
            return "mypy"
          end,
          prepend_args = {
            function()
              local cfg = vim.fs.find(
                { "mypy.ini", ".mypy.ini", "pyproject.toml", "setup.cfg" },
                { upward = true, path = vim.api.nvim_buf_get_name(0) }
              )[1]
              return cfg and ("--config-file=" .. cfg) or nil
            end,
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "mypy" } },
  },
}
