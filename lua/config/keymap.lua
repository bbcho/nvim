-- keymaps start at line 172
local wk = require("which-key")

P = function(x)
  print(vim.inspect(x))
  return (x)
end

RELOAD = function(...)
  return require 'plenary.reload'.reload_module(...)
end

R = function(name)
  RELOAD(name)
  return require(name)
end

local opts = { noremap = true, silent = true }

local nmap = function(key, effect)
  vim.keymap.set('n', key, effect, opts)
end

local vmap = function(key, effect)
  vim.keymap.set('v', key, effect, opts)
end

local imap = function(key, effect)
  vim.keymap.set('i', key, effect, opts)
end

local map = vim.api.nvim_set_keymap

-- functions for REPL and Jupyter
local CELL_MARKER_COLOR = "#C5C5C5"
local CELL_MARKER = "^# %%%%"
local CELL_MARKER_SIGN = "cell_marker_sign"

vim.api.nvim_set_hl(0, "cell_marker_hl", { bg = CELL_MARKER_COLOR })
vim.fn.sign_define(CELL_MARKER_SIGN, { linehl = "cell_marker_hl" })

local function highlight_cell_marker(bufnr, line)
  local sign_name = CELL_MARKER_SIGN
  local sign_text = "%%"
  vim.fn.sign_place(line, CELL_MARKER_SIGN, sign_name, bufnr, {
    lnum = line,
    priority = 10,
    text = sign_text,
  })
end

local function show_cell_markers()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.fn.sign_unplace(CELL_MARKER_SIGN, { buffer = bufnr })
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  for line = 1, total_lines do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content ~= "" and line_content:find(CELL_MARKER) then
      highlight_cell_marker(bufnr, line)
    end
  end
end

local function show_cell_marker()
  local bufnr = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
  if line_content ~= "" and line_content:find(CELL_MARKER) then
    highlight_cell_marker(bufnr, line)
  else
    vim.fn.sign_unplace(CELL_MARKER_SIGN, { buffer = bufnr, id = line })
  end
end

local function select_cell()
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

local function execute_cell()
  local current_row, current_col, start_line, end_line = select_cell()
  if start_line and end_line then
    vim.fn.setpos("'<", { 0, start_line + 1, 0, 0 })
    vim.fn.setpos("'>", { 0, end_line - 1, 0, 0 })
    require("iron.core").visual_send()
    vim.api.nvim_win_set_cursor(0, { current_row, current_col })
  end
end

local function delete_cell()
  local _, _, start_line, end_line = select_cell()
  if start_line and end_line then
    local rows_to_select = end_line - start_line - 1
    vim.api.nvim_win_set_cursor(0, { start_line, 0 })
    vim.cmd("normal!V " .. rows_to_select .. "j")
    vim.cmd "normal!d"
    vim.cmd "normal!k"
  end
end

local function navigate_cell(up)
  local is_up = up or false
  local _, _, start_line, end_line = select_cell()
  if is_up and start_line ~= 1 then
    vim.api.nvim_win_set_cursor(0, { start_line - 1, 0 })
  elseif end_line then
    local bufnr = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    if end_line ~= line_count then
      vim.api.nvim_win_set_cursor(0, { end_line + 1, 0 })
      _, _, start_line, end_line = select_cell()
      vim.api.nvim_win_set_cursor(0, { end_line - 1, 0 })
    end
  end
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

  vim.cmd "normal!2o"
  vim.api.nvim_buf_set_lines(bufnr, line, line + 1, false, { content })
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  highlight_cell_marker(bufnr, current_line - 1)
  vim.cmd "normal!2o"
  vim.cmd "normal!k"
end

local function insert_code_cell()
  insert_cell "# %%"
end

local function insert_markdown_cell()
  insert_cell "# %% [markdown]"
end

-- functions for REPL and Jupyter end

-- save with ctrl+s
imap("<C-s>", "<cmd>:w<cr><esc>")
nmap("<C-s>", "<cmd>:w<cr><esc>")

-- Move between windows using <ctrl> direction
nmap('<C-j>', '<C-W>j')
nmap('<C-k>', '<C-W>k')
nmap('<C-h>', '<C-W>h')
nmap('<C-l>', '<C-W>l')

-- Resize window using <shift> arrow keys
nmap("<S-Up>", "<cmd>resize +2<CR>")
nmap("<S-Down>", "<cmd>resize -2<CR>")
nmap("<S-Left>", "<cmd>vertical resize -2<CR>")
nmap("<S-Right>", "<cmd>vertical resize +2<CR>")

-- Add undo break-points
imap(",", ",<c-g>u")
imap(".", ".<c-g>u")
imap(";", ";<c-g>u")

nmap('Q', '<Nop>')

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap('<c-cr>', '<Plug>SlimeSendCell')
nmap('<s-cr>', '<Plug>SlimeSendCell')
imap('<c-cr>', '<esc><Plug>SlimeSendCell<cr>i')
imap('<s-cr>', '<esc><Plug>SlimeSendCell<cr>i')

-- send code with Enter and leader Enter
vmap('<cr>', '<Plug>SlimeRegionSend')
nmap('<leader><cr>', '<Plug>SlimeSendCell')


-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- remove search highlight on esc
nmap('<esc>', '<cmd>noh<cr>')

-- find files with telescope
nmap('<c-p>', "<cmd>Telescope find_files<cr>")

-- paste and without overwriting register
vmap("<leader>p", "\"_dP")

-- delete and without overwriting register
vmap("<leader>d", "\"_d")

-- center after search and jumps
nmap('n', "nzz")
nmap('<c-d>', '<c-d>zz')
nmap('<c-u>', '<c-u>zz')

-- move between splits and tabs
nmap('<c-h>', '<c-w>h')
nmap('<c-l>', '<c-w>l')
nmap('<c-j>', '<c-w>j')
nmap('<c-k>', '<c-w>k')
nmap('H', '<cmd>tabprevious<cr>')
nmap('L', '<cmd>tabnext<cr>')


-- Ben's Custom Keymaps



-- -- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

-- vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
-- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
-- vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
-- vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
-- vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })


-- Move to previous/next
map('n', '<C-,>', '<Cmd>BufferPrevious<CR>', opts)
map('n', '<C-.>', '<Cmd>BufferNext<CR>', opts)
-- Re-order to previous/next
map('n', '<C-<>', '<Cmd>BufferMovePrevious<CR>', opts)
map('n', '<C->>', '<Cmd>BufferMoveNext<CR>', opts)
-- Goto buffer in position...
map('n', '<C-1>', '<Cmd>BufferGoto 1<CR>', opts)
map('n', '<C-2>', '<Cmd>BufferGoto 2<CR>', opts)
map('n', '<C-3>', '<Cmd>BufferGoto 3<CR>', opts)
map('n', '<C-4>', '<Cmd>BufferGoto 4<CR>', opts)
map('n', '<C-5>', '<Cmd>BufferGoto 5<CR>', opts)
map('n', '<C-6>', '<Cmd>BufferGoto 6<CR>', opts)
map('n', '<C-7>', '<Cmd>BufferGoto 7<CR>', opts)
map('n', '<C-8>', '<Cmd>BufferGoto 8<CR>', opts)
map('n', '<C-9>', '<Cmd>BufferGoto 9<CR>', opts)
map('n', '<C-0>', '<Cmd>BufferLast<CR>', opts)
-- Pin/unpin buffer
-- map('n', '<C-p>', '<Cmd>BufferPin<CR>', opts)
-- Close buffer
map('n', '<C-c>', '<Cmd>BufferClose<CR>', opts)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
-- Sort automatically by...
map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

-- -- page up and down
-- map('n', '<C-d>', '<C-d>zz', opts)
-- map('n', '<C-u>', '<C-u>zz', opts)


local function toggle_light_dark_theme()
  if vim.o.background == 'light' then
    vim.o.background = 'dark'
    vim.cmd [[Catppuccin mocha]]
  else
    vim.o.background = 'light'
    vim.cmd [[Catppuccin latte]]
  end
end


--show kepbindings with whichkey
--add your own here if you want them to
--show up in the popup as well
wk.register(
  {
    n = {
      name = 'neotest',
      r = { ":lua require'neotest'.run.run()<cr>", 'run neotest'},
      f = { ":lua require'neotest'.run.run(vim.fn.expand('%'))<cr>", 'run neotest on curent file'},
      d = { ":lua require'neotest'.run.run({strategy = 'dap'})<cr>", 'debug nearest test'},
      s = { ":lua require'neotest'.run.stop()<cr>", 'stop nearest neotest'},
      n = { ":lua require'neotest'.run.attach()<cr>", 'run nearest neotest'},
      o = { ":lua require'neotest'.output_panel.toggle()<cr>", 'toggle neotest output'},
      x = { ":lua require'neotest'.jump.next({ status = 'failed' })<cr>", 'jump to next failure'},
      p = { ":lua require'neotest'.jump.prev({ status = 'failed' })<cr>", 'jump to prev failure'},
      u = { ":lua require'neotest'.summary.toggle()<cr>", 'toggle summary tree'},
    },
    i = {
      name = 'iron/jupyter',

      -- x = { execute_cell, "Execute Cell" },
      i = {
        name = 'cell',
        c = { insert_code_cell, "Insert Code Cell" },
        m = { insert_markdown_cell, "Insert Markdown Cell" },
        d = { delete_cell, "Delete Cell" },
      },
      n = { navigate_cell, "Next Cell" },
      p = { function() navigate_cell(true) end, "Previous Cell" },
      s = { function() require("iron.core").run_motion("send_motion") end, "Send Motion" },
      l = { function() require("iron.core").send_line() end, "Send Line" },
      t = { function() require("iron.core").send_until_cursor() end, "Send Until Cursor" },
      f = { function() require("iron.core").send_file() end, "Send File" },
      ["<cr>"] = { function() require("iron.core").send(nil, string.char(13)) end, "ENTER" },
      I = { function() require("iron.core").send(nil, string.char(03)) end, "Interrupt" },
      C = { function() require("iron.core").close_repl() end, "Close REPL" },
      c = { function() require("iron.core").send(nil, string.char(12)) end, "Clear" },
      m = { 
        name = 'mark',
        s = { function() require("iron.core").send_mark() end, "Send Mark" },
        m = { function() require("iron.core").run_motion("mark_motion") end, "Mark Motion" },
        r = { function() require("iron.marks").drop_last() end, "Remove Mark" },
      },
      R = { "<cmd>IronRepl<cr>", "REPL" },
      S = { "<cmd>IronRestart<cr>", "Restart" },
      F = { "<cmd>IronFocus<cr>", "Focus" },
      H = { "<cmd>IronHide<cr>", "Hide" }
    },
    p = {
      name = 'explorer',
      v = {vim.cmd.Ex, 'file explorer' },
    },
    c = {
      name = 'code',
      c = { ':SlimeConfig<cr>', 'slime config' },
      n = { ':split term://$SHELL<cr>', 'new terminal' },
      r = { ':split term://R<cr>', 'new R terminal' },
      p = { ':split term://python<cr>', 'new python terminal' },
      i = { ':split term://ipython<cr>', 'new ipython terminal' },
      j = { ':split term://julia<cr>', 'new julia terminal' },
    },
    v = {
      name = 'vim',
      t = { toggle_light_dark_theme, 'switch theme' },
      c = { ':Telescope colorscheme<cr>', 'colortheme' },
      l = { ':Lazy<cr>', 'Lazy' },
      m = { ':Mason<cr>', 'Mason' },
      s = { ':e $MYVIMRC | :cd %:p:h | split . | wincmd k<cr>', 'Settings' },
      h = { ':execute "h " . expand("<cword>")<cr>', 'help' }
    },
    l = {
      name = 'language/lsp',
      r    = { '<cmd>Telescope lsp_references<cr>', 'references' },
      R    = { vim.lsp.buf.rename, 'rename' },
      D    = { vim.lsp.buf.type_definition, 'type definition' },
      a    = { vim.lsp.buf.code_action, 'coda action' },
      e    = { vim.diagnostic.open_float, 'diagnostics' },
      f    = { vim.lsp.buf.format, 'format' },
      o    = { ':SymbolsOutline<cr>', 'outline' },
      d    = {
        name = 'diagnostics',
        d = { vim.diagnostic.disable, 'disable' },
        e = { vim.diagnostic.enable, 'enable' },
      },
      g    = { ':Neogen<cr>', 'neogen docstring' },
      s    = { ':ls!<cr>', 'list all buffers' },
    },
    q = {
      name = 'quarto',
      a = { ":QuartoActivate<cr>", 'activate' },
      p = { ":lua require'quarto'.quartoPreview()<cr>", 'preview' },
      q = { ":lua require'quarto'.quartoClosePreview()<cr>", 'close' },
      h = { ":QuartoHelp ", 'help' },
      r = { name = 'run',
        r = { ':QuartoSendAbove<cr>', 'to cursor' },
        a = { ':QuartoSendAll<cr>', 'all' },
      },
      e = { ":lua require'otter'.export()<cr>", 'export' },
      E = { ":lua require'otter'.export(true)<cr>", 'export overwrite' },
    },
    f = {
      name = 'find (telescope)',
      f = { '<cmd>Telescope find_files<cr>', 'files' },
      h = { '<cmd>Telescope help_tags<cr>', 'help' },
      k = { '<cmd>Telescope keymaps<cr>', 'keymaps' },
      r = { '<cmd>Telescope lsp_references<cr>', 'references' },
      g = { "<cmd>Telescope live_grep<cr>", "grep" },
      b = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "fuzzy" },
      m = { "<cmd>Telescope marks<cr>", "marks" },
      M = { "<cmd>Telescope man_pages<cr>", "man pages" },
      c = { "<cmd>Telescope git_commits<cr>", "git commits" },
      s = { "<cmd>Telescope lsp_document_symbols<cr>", "symbols" },
      d = { "<cmd>Telescope buffers<cr>", "buffers" },
      q = { "<cmd>Telescope quickfix<cr>", "quickfix" },
      l = { "<cmd>Telescope loclist<cr>", "loclist" },
      j = { "<cmd>Telescope jumplist<cr>", "marks" },
      p = { "project" },
    },
    h = {
      name = 'help/debug/conceal',
      c = {
        name = 'conceal',
        h = { ':set conceallevel=1<cr>', 'hide/conceal' },
        s = { ':set conceallevel=0<cr>', 'show/unconceal' },
      },
      t = {
        name = 'treesitter',
        t = { vim.treesitter.inspect_tree, 'show tree' },
        c = { ':=vim.treesitter.get_captures_at_cursor()<cr>', 'show capture' },
        n = { ':=vim.treesitter.get_node():type()<cr>', 'show node' },
      }
    },
    s = {
      name = "spellcheck",
      s = { "<cmd>Telescope spell_suggest<cr>", "spelling" },
      ['/'] = { '<cmd>setlocal spell!<cr>', 'spellcheck' },
      n = { ']s', 'next' },
      p = { '[s', 'previous' },
      g = { 'zg', 'good' },
      r = { 'zg', 'rigth' },
      w = { 'zw', 'wrong' },
      b = { 'zw', 'bad' },
      ['?'] = { '<cmd>Telescope spell_suggest<cr>', 'suggest' },
    },
    g = {
      name = "git",
      c = { ":GitConflictRefresh<cr>", 'conflict' },
      g = { ":Neogit<cr>", "neogit" },
      s = { ":Gitsigns<cr>", "gitsigns" },
      pl = { ":Octo pr list<cr>", "gh pr list" },
      pr = { ":Octo review start<cr>", "gh pr review" },
      wc = { ":lua require('telescope').extensions.git_worktree.create_git_worktree()<cr>", "worktree create" },
      ws = { ":lua require('telescope').extensions.git_worktree.git_worktrees()<cr>", "worktree switch" },
      d = {
        name = 'diff',
        o = { ':DiffviewOpen<cr>', 'open' },
        c = { ':DiffviewClose<cr>', 'close' },
      }
    },
    w = {
      name = 'write',
      w = { ":w<cr>", "write" },
    },
    x = {
      name = 'execute',
      x = { ':w<cr>:source %<cr>', 'file' }
    }
  }, { mode = 'n', prefix = '<leader>' }
)


-- normal mode
wk.register({
  ['<c-LeftMouse>'] = { '<cmd>lua vim.lsp.buf.definition()<CR>', 'go to definition' },
  ["<c-q>"]         = { '<cmd>q<cr>', 'close buffer' },
  ['<esc>']         = { '<cmd>noh<cr>', 'remove search highlight' },
  ['n']             = { 'nzzzv', 'center search' },
  ['gN']            = { 'Nzzzv', 'center search' },
  ['gl']            = { '<c-]>', 'open help link' },
  ['gf']            = { ':e <cfile><CR>', 'edit file' },
  ['coo']            = { 'o#%%<cr>', 'new code chunk below' },
  ['cOo']            = { 'O#%%<cr>', 'new code chunk above' },
  ['cob']           = { 'o```{bash}<cr>```<esc>O', "bash code chunk" },
  ['cor']           = { 'o```{r}<cr>```<esc>O', "r code chunk" },
  ['cop']           = { 'o```{python}<cr>```<esc>O', "python code chunk" },
  ['col']           = { 'o```{julia}<cr>```<esc>O', "julia code chunk" },
  ['<m-i>']         = { 'o```{r}<cr>```<esc>O', "r code chunk" },
  ['<cm-i>']        = { 'o```{python}<cr>```<esc>O', "r code chunk" },
  ['<m-I>']         = { 'o```{python}<cr>```<esc>O', "r code chunk" },
}, { mode = 'n' })


-- visual mode
wk.register({
  ['<cr>'] = { '<Plug>SlimeRegionSend', 'run code region' },
  ['<M-j>'] = { ":m'>+<cr>`<my`>mzgv`yo`z", 'move line down' },
  ['<M-k>'] = { ":m'<-2<cr>`>my`<mzgv`yo`z", 'move line up' },
  ['.'] = { ':norm .<cr>', 'repat last normal mode command' },
  ['q'] = { ':norm @q<cr>', 'repat q macro' },
}, { mode = 'v' })

wk.register({
  ['<leader>'] = { '<Plug>SlimeRegionSend', 'run code region' },
  ['p'] = { '"_dP', 'replace without overwriting reg' },
  i = {
    name = 'iron/jupyter',
    s = { function() require("iron.core").visual_send() end, "Send" },
    L = { function() require("iron.marks").clear_hl() end, "Clear Highlight" },
    m = {
      name = 'mark',
      v = { function() require("iron.core").mark_visual() end, "Mark Visual" }, 
    }
  },
}, { mode = 'v', prefix = "<leader>" })


vim.cmd('autocmd FileType * lua setKeybinds()')
vim.cmd('autocmd VimEnter lua setKeybinds()')
function setKeybinds()
  local fileTy = vim.api.nvim_buf_get_option(0, "filetype")
  local opts = { prefix = '<localleader>', buffer = 0 }

  if fileTy == 'r' then
    wk.register({
      -- ['<c-e>'] = { "<esc>:FeMaco<cr>i", "edit code" },
      ['<C-=>'] = { ' <- ', "assign" },
      ['<C-.>'] = { ' |> ', "pipe" },
    }, { mode = 'i' })
  elseif fileTy == 'quarto' then
    wk.register({
      -- ['<c-e>'] = { "<esc>:FeMaco<cr>i", "edit code" },
      ['<C-=>'] = { ' <- ', "assign" },
      ['<C-.>'] = { ' |> ', "pipe" },
      ['<C-r>'] = { '```{r}<cr>```<esc>O', "r code chunk" },
      -- ['<cm-i>'] = { '<esc>o```{python}<cr>```<esc>O', "r code chunk" },
      ['<C-p>'] = { '<esc>o```{python}<cr>```<esc>O', "python code chunk" },
    }, { mode = 'i' })
  end
end

