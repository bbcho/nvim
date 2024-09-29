-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local quarto = require("quarto")
quarto.setup()

vim.keymap.set("n", "<leader>qp", '<cmd>lua require("quarto").quartoPreview()<CR>', { desc = "Quarto Preview" })
vim.keymap.set("n", "<leader>qc", '<cmd>lua require("quarto").quartoClosePreview()<CR>', { desc = "Quarto Preview" })

----------------------------------
-- MOLTEN KEYMAPS and FUNCTIONS --
----------------------------------

vim.keymap.set("n", "<leader>mm", "<cmd>lua execute_cell()<CR>", { silent = true, desc = "Execute Cell" })
vim.keymap.set("n", "<leader>mI", "<cmd>MoltenInterupt<CR>", { silent = true, desc = "Execute Cell" })
vim.keymap.set("n", "<leader>mR", "<cmd>MoltenRestart!<CR>", { silent = true, desc = "Execute Cell" })
vim.keymap.set(
  "n",
  "<leader>mn",
  ":lua execute_cell_next()<CR>",
  { silent = true, desc = "Execute Cell and Move to Next Cell" }
)
vim.keymap.set("n", "<leader>me", "<cmd>noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Enter Output" })
vim.keymap.set("n", "<leader>md", "<cmd>lua next_cell()<CR>", { silent = true, desc = "Next Cell" })
vim.keymap.set("n", "<leader>mu", "<cmd>lua prev_cell()<CR>", { silent = true, desc = "Prev Cell" })
vim.keymap.set("n", "<leader>mi", "<cmd>MoltenInit python<CR>", { silent = true, desc = "MoltenInit python" })
vim.keymap.set("n", "<leader>ml", "<cmd>MoltenEvaluateLine<CR>", { silent = true, desc = "Molten Evaluate Line" })
vim.keymap.set(
  "n",
  "<leader>mv",
  "<cmd><C-u>MoltenEvaluateVisual<CR>gv",
  { silent = true, desc = "Molten Evaluate Visual" }
)
vim.keymap.set(
  "n",
  "<leader>mo",
  "<cmd>MoltenEvaluateOperator<CR>",
  { silent = true, desc = "Molten Evaluate Operator" }
)
vim.keymap.set("n", "<leader>ma", "<cmd>lua insert_code_cell()<CR>", { silent = true, desc = "Insert Code Cell" })
vim.keymap.set(
  "n",
  "<leader>mA",
  "<cmd>lua insert_code_cell_above()<CR>",
  { silent = true, desc = "Insert Code Cell Above" }
)
vim.keymap.set(
  "n",
  "<leader>mk",
  "<cmd>lua insert_markdown_cell()<CR>",
  { silent = true, desc = "Insert Markdown Cell" }
)
vim.keymap.set(
  "n",
  "<leader>mK",
  "<cmd>lua insert_markdown_cell_above()<CR>",
  { silent = true, desc = "Insert Markdown Cell Above" }
)
vim.keymap.set("n", "<leader>mD", "<cmd>lua delete_cell()<CR>", { silent = true, desc = "Delete Cell" })

local function select_cell()
  local fileTy = vim.api.nvim_buf_get_option(0, "filetype")

  if fileTy == "python" then
    CELL_MARKER = "^# %%%%"
  elseif fileTy == "quarto" then
    CELL_MARKER = "^```"
  elseif fileTy == "r" then
    CELL_MARKER = "^# %%%%"
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local current_row = vim.api.nvim_win_get_cursor(0)[1]
  local current_col = vim.api.nvim_win_get_cursor(0)[2]

  local start_line = nil
  local end_line = nil

  for line = current_row, 1, -1 do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find(CELL_MARKER) then
      start_line = line
      break
    end
  end
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  for line = current_row + 1, line_count do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find(CELL_MARKER) then
      end_line = line
      break
    end
  end

  if not start_line then
    start_line = 1
  end
  if not end_line then
    end_line = line_count
  end
  return current_row, current_col, start_line, end_line
end

function execute_cell()
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    vim.fn.setpos("'<", { 0, start_line + 1, 0, 0 })
    vim.fn.setpos("'>", { 0, end_line - 1, 0, 0 })

    -- Execute MoltenEvaluateVisual command
    vim.api.nvim_command("MoltenEvaluateVisual")

    vim.api.nvim_win_set_cursor(0, { current_row, current_col })
  end
end

function execute_cell_next()
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    vim.fn.setpos("'<", { 0, start_line + 1, 0, 0 })
    vim.fn.setpos("'>", { 0, end_line - 1, 0, 0 })

    vim.cmd("MoltenEvaluateVisual")
    -- require("iron.core").visual_send()
    vim.api.nvim_win_set_cursor(0, { end_line + 1, current_col })
  end
end

function next_cell()
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if end_line ~= line_count then
      vim.api.nvim_win_set_cursor(0, { end_line + 1, current_col })
    end
  end
end

function prev_cell()
  vim.cmd("echo 'prev cell'")
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    if start_line ~= 1 then
      vim.api.nvim_win_set_cursor(0, { start_line - 1, current_col })
    end
  end
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    vim.api.nvim_win_set_cursor(0, { start_line + 1, current_col })
  end
end

local function insert_cell_above(content)
  local _, _, start_line, _ = select_cell()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = start_line
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })

  if start_line == 1 then
    vim.cmd("normal!O") -- if this is the first cell, add an empty row above it
    vim.cmd("normal!x") -- delete leading #
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  end

  vim.cmd("normal!k")
  vim.cmd("normal!2O")
  vim.api.nvim_buf_set_lines(bufnr, line - 1, line, false, { content })
  vim.cmd("normal!j")
  vim.cmd("normal!2o")
  vim.cmd("normal!k")
end

local function insert_cell(content)
  local _, _, _, end_line = select_cell()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = end_line
  if end_line ~= 1 then
    line = end_line - 1
    vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
  else
    line = end_line
    vim.api.nvim_win_set_cursor(0, { end_line, 0 })
  end

  vim.cmd("normal!2o")
  vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { content })
  -- local current_line = vim.api.nvim_win_get_cursor(0)[1]
  -- highlight_cell_marker(bufnr, current_line - 1)
  vim.cmd("normal!2o")
  vim.cmd("normal!k")
end

function insert_code_cell()
  insert_cell("# %%")
end

function insert_code_cell_above()
  insert_cell_above("# %%")
end

function insert_markdown_cell()
  insert_cell("# %% [markdown]")
end

function insert_markdown_cell_above()
  insert_cell_above("# %% [markdown]")
end

function delete_cell()
  local _, _, start_line, end_line = select_cell()
  if start_line and end_line then
    local rows_to_select = end_line - start_line - 1
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    vim.cmd("normal!V " .. rows_to_select .. "j")
    vim.cmd("normal!d")
    vim.cmd("normal!k")
  end
end
