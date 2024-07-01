return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- for friendly snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      -- for custom snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snips" } })
    end,
    requires = {
      "rafamadriz/friendly-snippets",
    },
  },
}
