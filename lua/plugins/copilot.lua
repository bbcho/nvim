return {
  -- 'github/copilot.vim',
  'zbirenbaum/copilot.lua',
  config = function()
    require 'copilot'.setup {
      suggestion = { enabled = false },
      panel = { enabled = false },
      autorefresh = true,
      -- -- Copilot Setup
      -- copilot_no_tab_map = true,
      -- copilot_assume_mapped = true,
      -- copilot_tab_fallback = "",
    }
  end
}


