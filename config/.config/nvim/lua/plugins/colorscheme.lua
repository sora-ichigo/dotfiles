return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    priority = 1100,
    config = function()
      require("transparent").setup({
        extra_groups = {
          "NormalFloat",
          "NeoTreeNormal",
          "NeoTreeNormalNC",
          "NvimTreeNormal",
          "TelescopeNormal",
          "TelescopeBorder",
          "WhichKeyFloat",
          "LazyNormal",
          "MasonNormal",
          "NoiceCmdlinePopup",
          "NoicePopup",
          "MsgArea",
          "MsgSeparator",
          "FloatBorder",
          "StatusLine",
          "StatusLineNC",
          "WinBar",
          "WinBarNC",
          "TabLine",
          "TabLineFill",
          "TabLineSel",
        },
      })
      for _, prefix in ipairs({ "lualine", "Snacks", "Mini", "NeoTree", "Telescope", "Lazy" }) do
        require("transparent").clear_prefix(prefix)
      end
      vim.g.transparent_enabled = true
    end,
  },
}
