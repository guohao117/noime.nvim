local M = {}

-- Configuration
local config = {
  debug = false,
  auto_switch = true,
}

-- Plugin state
local state = {
  setup_done = false,
  current_mode = nil,
  is_insert_mode = false,
}

-- Utility functions
local function is_wezterm_env()
  return vim.env.WEZTERM_PANE or (vim.env.TERM and vim.env.TERM:match("wezterm"))
end

local function log(msg)
  if config.debug then
    print("[IME Helper] " .. msg)
  end
end

-- Core IME switching via WezTerm OSC sequences
local function send_ime_command(ime_state)
  -- Check for WezTerm environment - support both local and remote sessions
  if not is_wezterm_env() then
    log("Not in WezTerm environment, skipping IME command")
    return
  end
  
  -- Send OSC sequence to WezTerm (matches your WezTerm plugin)
  local osc_value = (ime_state == "EN") and "RU4=" or "SU1F" -- base64 encoded
  local osc_sequence = string.format("\027]1337;SetUserVar=wezterm_ime_control=%s\007", osc_value)
  
  io.write(osc_sequence)
  io.flush()
  
  log("Switched to " .. ime_state)
end

local function switch_to_en()
  send_ime_command("EN")
end

local function switch_to_ime()
  send_ime_command("IME")
end

-- Mode change handlers
local function on_insert_enter()
  if not config.auto_switch then return end
  
  state.is_insert_mode = true
  
  -- Do NOT switch IME when entering insert mode
  -- Let user control IME through OS
  log("Entered insert mode - keeping current IME state")
end

local function on_insert_leave()
  if not config.auto_switch then return end
  
  if state.is_insert_mode then
    state.is_insert_mode = false
  end
  
  -- Always switch to English when leaving insert mode
  switch_to_en()
  log("Left insert mode - switched to English")
end

local function on_mode_change()
  local mode = vim.api.nvim_get_mode().mode
  
  if state.current_mode == mode then
    return
  end
  
  state.current_mode = mode
  log("Mode changed to: " .. mode)
  
  -- Handle insert mode
  if mode == "i" or mode == "ic" or mode == "ix" then
    if not state.is_insert_mode then
      on_insert_enter()
    end
  else
    -- Non-insert mode - always ensure English
    if state.is_insert_mode then
      on_insert_leave()
    else
      -- Ensure English in all non-insert modes
      if config.auto_switch then
        switch_to_en()
      end
    end
  end
end

-- Setup autocmds
local function setup_autocmds()
  local group = vim.api.nvim_create_augroup("IMEHelper", { clear = true })
  
  -- Mode change detection
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = group,
    callback = on_mode_change,
    desc = "IME Helper: Handle mode changes"
  })
  
  -- Insert mode events (backup detection)
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = group,
    callback = on_insert_enter,
    desc = "IME Helper: Enter insert mode"
  })
  
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = on_insert_leave,
    desc = "IME Helper: Leave insert mode"
  })
  
  -- Initialize on startup
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    callback = function()
      switch_to_en()
      log("Initialized - switched to English")
    end,
    desc = "IME Helper: Initialize"
  })
  
  -- Cleanup on exit
  vim.api.nvim_create_autocmd("VimLeave", {
    group = group,
    callback = function()
      switch_to_en()
    end,
    desc = "IME Helper: Cleanup"
  })
end

-- Public API
function M.setup(opts)
  if state.setup_done then
    return
  end
  
  if not is_wezterm_env() then
    if opts and opts.debug then
      vim.notify("[IME Helper] Not in WezTerm, disabled", vim.log.levels.WARN)
    end
    return
  end
  
  -- Merge config
  config = vim.tbl_extend("force", config, opts or {})
  
  setup_autocmds()
  state.setup_done = true
  
  -- Initialize current mode
  on_mode_change()
  
  log("Setup completed")
end

function M.switch_to_en()
  switch_to_en()
  log("Manually switched to EN")
end

function M.switch_to_ime()
  switch_to_ime()
  log("Manually switched to IME")
end

function M.status()
  local status = {
    setup_done = state.setup_done,
    current_mode = state.current_mode,
    is_insert_mode = state.is_insert_mode,
    wezterm_pane = vim.env.WEZTERM_PANE,
    term_env = vim.env.TERM,
    is_wezterm_env = is_wezterm_env(),
    config = config,
  }
  print("IME Helper Status:")
  print(vim.inspect(status))
end

function M.is_setup()
  return state.setup_done
end

return M