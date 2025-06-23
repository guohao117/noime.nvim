-- Plugin entry point - auto-loaded by Neovim
if vim.g.loaded_wezterm_ime_helper then
  return
end
vim.g.loaded_wezterm_ime_helper = 1

-- Only load if in WezTerm
if not vim.env.WEZTERM_PANE then
  return
end

-- Create user commands
vim.api.nvim_create_user_command('IMESwitchToEN', function()
  require('ime-helper').switch_to_en()
end, { desc = 'Switch to English IME' })

vim.api.nvim_create_user_command('IMESwitchToIME', function()
  require('ime-helper').switch_to_ime()
end, { desc = 'Switch to IME' })

vim.api.nvim_create_user_command('IMEStatus', function()
  require('ime-helper').status()
end, { desc = 'Show IME status' })

-- Auto-initialize with default settings
vim.defer_fn(function()
  if not require('ime-helper').is_setup() then
    require('ime-helper').setup()
  end
end, 50)