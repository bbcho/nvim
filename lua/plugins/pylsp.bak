return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
      autostart = false,
      handlers = {
        ["window/logMessage"] = function(err, method, params, client_id)
          if params and params.type <= vim.lsp.protocol.MessageType.Log then
            vim.lsp.handlers["window/logMessage"](err, method, params, client_id)
          end
        end,
        ["window/showMessage"] = function(err, method, params, client_id)
          if params and params.type <= vim.lsp.protocol.MessageType.Warning.Error then
            vim.lsp.handlers["window/showMessage"](err, method, params, client_id)
          end
        end,
      },
    })

    lspconfig.pylsp.setup({})

    lspconfig.pylsp.setup({
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              maxLineLength = 100,
            },
          },
        },
      },
    })
  end,
}
