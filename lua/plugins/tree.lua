return {
  { 'kyazdani42/nvim-tree.lua',
    config = function()
      require 'nvim-tree'.setup {
        auto_reload_on_write = true,
        disable_netrw = true,
        hijack_netrw = true,
        -- open_on_setup       = false,
        update_focused_file = {
          enable = true,
        },
        git                 = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        diagnostics         = {
          enable = true,
        },
        actions              = {
          open_file = {
            resize_window = false,
          },
        }
      }
    end
  },
    
}
