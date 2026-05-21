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
          "TelescopePromptNormal",
          "TelescopePromptBorder",
          "TelescopeResultsNormal",
          "TelescopeResultsBorder",
          "TelescopePreviewNormal",
          "TelescopePreviewBorder",
          "TelescopePromptTitle",
          "TelescopeResultsTitle",
          "TelescopePreviewTitle",
          "SnacksPicker",
          "SnacksPickerBorder",
          "SnacksPickerTitle",
          "SnacksPickerInput",
          "SnacksPickerInputBorder",
          "SnacksPickerInputTitle",
          "SnacksPickerList",
          "SnacksPickerListBorder",
          "SnacksPickerListTitle",
          "SnacksPickerPreview",
          "SnacksPickerPreviewBorder",
          "SnacksPickerPreviewTitle",
          "SnacksDashboardNormal",
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
      for _, prefix in ipairs({ "lualine", "Mini", "NeoTree", "Lazy" }) do
        require("transparent").clear_prefix(prefix)
      end
      vim.g.transparent_enabled = true
    end,
  },
}
