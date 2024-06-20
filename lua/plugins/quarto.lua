return {
  {
    "quarto-dev/quarto-nvim",
    dev = false,
    ft = { "quarto" },
    dependencies = {
      "jmbuhr/otter.nvim",
    },
    config = function()
      require("quarto").setup({
        debuf = false,
        closePreviewOnQuit = true,
        lspFeatures = {
          enabled = true, -- default is false
          chunks = "curly", -- default is "curly"
          languages = { "r", "python" }, -- default is {"r"}, can be "r", "python", "julia", "scala", "sql", "bash",
          diagnostics = {
            enabled = true, -- default is false
            triggers = { "BugWritePost" },
          },
          completion = {
            enabled = true, -- default is false
          },
          keymap = {
            hover = "K",
            definition = "gd",
          },
        },
      })
    end,
  },
}
