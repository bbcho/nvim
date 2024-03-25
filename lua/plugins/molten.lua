return {
    { 
        '3rd/image.nvim',
        config = function() 
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/scoop/apps/lua-for-windows/rocks/?/init.lua;"
            package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/scoop/apps/lua-for-windows/rocks/?.lua;"
            require 'image'.setup {
                backend = 'kitty',
                integrations = {
                      markdown = {
                      enabled = true,
                      clear_in_insert_mode = false,
                      download_remote_images = true,
                      only_render_image_at_cursor = false,
                      filetypes = { "markdown", "vimwiki", "quarto" }, -- markdown extensions (ie. quarto) can go here
                    },
                },
                max_width = 100,
                max_height = 12,
                max_height_window_percentage = math.huge,
                max_height_window_percentage = math.huge,
                window_overlap_clear_enabled = true,
                window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
            }
        end,
    },
    {
        'benlubas/molten-nvim',
        version = "^1.0.0",
        build = ":UpdateRemotePlugins",
        dependencies = { "3rd/image.nvim" },
        init = function()
            -- these are examples, not defaults. Please see the readme
            vim.g.molten_image_provider = "image.nvim"
            vim.g.molten_output_win_max_height = 20
        end,
    },
}
