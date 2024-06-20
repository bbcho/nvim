-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local quarto = require("quarto")
quarto.setup()

vim.keymap.set("n", "<leader>qp", '<cmd>lua require("quarto").quartoPreview()<CR>', { desc = "Quarto Preview" })
vim.keymap.set("n", "<leader>qc", '<cmd>lua require("quarto").quartoClosePreview()<CR>', { desc = "Quarto Preview" })
