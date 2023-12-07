return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-calc' },
      { 'hrsh7th/cmp-emoji' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'f3fora/cmp-spell' },
      { 'ray-x/cmp-treesitter' },
      { 'kdheepak/cmp-latex-symbols' },
      { 'jmbuhr/cmp-pandoc-references' },
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },
      { 'onsails/lspkind-nvim' },

      -- optional
      -- more things to try:
      {
        "zbirenbaum/copilot-cmp",
        after = { "copilot.lua" },
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
          require("copilot").setup({
            suggestion = { enabled = true },
            panel = { enabled = true },
          })
          require("copilot_cmp").setup()
        end
      },

    },
    
    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-CR>"] = function(fallback)
            cmp.abort()
            fallback()
          end,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
        -- formatting = {
        --   format = function(_, item)
        --     local icons = require("lazyvim.config").icons.kinds
        --     if icons[item.kind] then
        --       item.kind = icons[item.kind] .. item.kind
        --     end
        --     return item
        --   end,
        -- },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
        },
        sorting = defaults.sorting,
      }
    end,
    
    config = function(_, opts)
      local lspkind = require "lspkind"
      local cmp = require 'cmp'
      local lspkind = require "lspkind"
      lspkind.init()
      for _, source in ipairs(opts.sources) do
        source.group_index = source.group_index or 1
      end
      require("cmp").setup(opts)
      cmp.setup({
        formatting = {
          format = lspkind.cmp_format {
            with_text = true,
            menu = {
              otter = "[🦦]",
              copilot = '[]',
              luasnip = "[snip]",
              nvim_lsp = "[LSP]",
              buffer = "[buf]",
              path = "[path]",
              spell = "[spell]",
              pandoc_references = "[ref]",
              tags = "[tag]",
              treesitter = "[TS]",
              calc = "[calc]",
              latex_symbols = "[tex]",
              emoji = "[emoji]",
            },
          },
        },
        sources = {
          { name = 'copilot',                keyword_length = 0, max_item_count = 3 },
          { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip',                keyword_length = 3, max_item_count = 3 },
          { name = 'pandoc_references' },
          { name = 'buffer',                 keyword_length = 5, max_item_count = 3 },
          { name = 'spell' },
          { name = 'treesitter',             keyword_length = 5, max_item_count = 3 },
          { name = 'calc' },
          { name = 'latex_symbols' },
          { name = 'emoji' },
        },
        -- view = {
        --   -- entries = "native",
        --   entries = "auto",
        -- },
        window = {
          documentation = {
            border = require 'misc.style'.border,
          },
        },
      })
    end,

    -- config = function()
    --   local cmp = require 'cmp'
    --   local luasnip = require 'luasnip'
    --   local lspkind = require "lspkind"
    --   lspkind.init()
    --
    --
    --   local has_words_before = function()
    --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --     return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    --   end
    --
    --   cmp.setup({
    --     snippet = {
    --       expand = function(args)
    --         luasnip.lsp_expand(args.body)
    --       end,
    --     },
    --     mapping = {
    --       -- ['<C-f>'] = cmp.mapping.scroll_docs(-4),
    --       ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    --       ['<C-d>'] = cmp.mapping.scroll_docs(4),
    --       ['<C-n>'] = cmp.mapping(function(fallback)
    --         if luasnip.expand_or_jumpable() then
    --           luasnip.expand_or_jump()
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       ['<C-p>'] = cmp.mapping(function(fallback)
    --         if luasnip.jumpable(-1) then
    --           luasnip.jump(-1)
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       ['<c-a>'] = cmp.mapping.complete(),
    --       ['<C-e>'] = cmp.mapping.abort(),
    --       ['<Tab>'] = cmp.mapping.confirm({
    --         select = true,
    --       }),
    --       -- ["<Tab>"] = cmp.mapping(function(fallback)
    --       ["<Down>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_next_item()
    --         elseif has_words_before() then
    --           cmp.complete()
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       -- ["<S-Tab>"] = cmp.mapping(function(fallback)
    --       ["<Up>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_prev_item()
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --     },
    --     autocomplete = false,
    --     formatting = {
    --       format = lspkind.cmp_format {
    --         with_text = true,
    --         menu = {
    --           otter = "[🦦]",
    --           copilot = '[]',
    --           luasnip = "[snip]",
    --           nvim_lsp = "[LSP]",
    --           buffer = "[buf]",
    --           path = "[path]",
    --           spell = "[spell]",
    --           pandoc_references = "[ref]",
    --           tags = "[tag]",
    --           treesitter = "[TS]",
    --           calc = "[calc]",
    --           latex_symbols = "[tex]",
    --           emoji = "[emoji]",
    --         },
    --       },
    --     },
    --     sources = {
    --       { name = 'copilot',                keyword_length = 0, max_item_count = 3 },
    --       { name = 'otter' }, -- for code chunks in quarto
    --       { name = 'path' },
    --       { name = 'nvim_lsp' },
    --       { name = 'nvim_lsp_signature_help' },
    --       { name = 'luasnip',                keyword_length = 3, max_item_count = 3 },
    --       { name = 'pandoc_references' },
    --       { name = 'buffer',                 keyword_length = 5, max_item_count = 3 },
    --       { name = 'spell' },
    --       { name = 'treesitter',             keyword_length = 5, max_item_count = 3 },
    --       { name = 'calc' },
    --       { name = 'latex_symbols' },
    --       { name = 'emoji' },
    --     },
    --     view = {
    --       entries = "native", # or auto, left, right, top etc..
    --     },
    --     window = {
    --       documentation = {
    --         border = require 'misc.style'.border,
    --       },
    --     },
    --   })
    --   -- for friendly snippets
    --   require("luasnip.loaders.from_vscode").lazy_load()
    --   -- for custom snippets
    --   require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/nvim/snips" } })
    -- end
  },

}
