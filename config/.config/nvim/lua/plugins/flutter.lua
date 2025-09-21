return {
  {
    "nvim-flutter/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    config = function()
      require("flutter-tools").setup({
        ui = {
          border = "rounded",
          notification_style = "native",
        },
        decorations = {
          statusline = {
            app_version = false,
            device = true,
            project_config = false,
          },
        },
        widget_guides = {
          enabled = true,
        },
        closing_tags = {
          highlight = "ErrorMsg",
          prefix = "// ",
          priority = 10,
          enabled = true,
        },
        dev_log = {
          enabled = true,
          notify_errors = false,
          open_cmd = "tabedit",
          focus_on_open = false,
        },
        dev_tools = {
          autostart = false,
          auto_open_browser = false,
        },
        outline = {
          open_cmd = "30vnew",
          auto_open = false,
        },
        lsp = {
          color = {
            enabled = true,
            background = false,
            foreground = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            analysisExcludedFolders = {
              vim.fn.expand("~/.pub-cache"),
              vim.fn.expand("~/flutter"),
            },
            renameFilesWithClasses = "prompt",
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
        },
      })
    end,
    keys = {
      { "<leader>fs", "<cmd>FlutterRun<cr>", desc = "Flutter Run" },
      { "<leader>fd", "<cmd>FlutterDevices<cr>", desc = "Flutter Devices" },
      { "<leader>fe", "<cmd>FlutterEmulators<cr>", desc = "Flutter Emulators" },
      { "<leader>fr", "<cmd>FlutterReload<cr>", desc = "Flutter Reload" },
      { "<leader>fR", "<cmd>FlutterRestart<cr>", desc = "Flutter Restart" },
      { "<leader>fq", "<cmd>FlutterQuit<cr>", desc = "Flutter Quit" },
      { "<leader>fD", "<cmd>FlutterDetach<cr>", desc = "Flutter Detach" },
      { "<leader>fo", "<cmd>FlutterOutlineToggle<cr>", desc = "Flutter Outline Toggle" },
      { "<leader>ft", "<cmd>FlutterDevTools<cr>", desc = "Flutter DevTools" },
      { "<leader>fc", "<cmd>FlutterLogClear<cr>", desc = "Flutter Log Clear" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>f", group = "flutter", icon = " " },
      },
    },
  },
}