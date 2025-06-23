# noime.nvim

A Neovim plugin that automatically switches to English input method when leaving insert mode in WezTerm. This prevents input method editor (IME) popups from interfering with Neovim operations in normal, visual, and command modes.

## Features

- 🎯 **Automatic IME switching**: Automatically switches to English input method when leaving insert mode
- 🌐 **Remote session support**: Works in both local and remote sessions via OSC 1337 escape sequences
- ⚡ **WezTerm optimized**: Specifically designed to work with [guohao117/wezterm-ime-helper](https://github.com/guohao117/wezterm-ime-helper)
- 🔧 **Manual commands**: Easy-to-use commands for manual control
- 📦 **Zero dependencies**: Lightweight with no external dependencies

## Requirements

- Neovim 0.7+
- [WezTerm](https://wezfurlong.org/wezterm/) terminal
- [wezterm-ime-helper](https://github.com/guohao117/wezterm-ime-helper) plugin installed in WezTerm

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "guohao117/noime.nvim",
  event = "VeryLazy",
  cond = function()
    -- Load in WezTerm environment (both local and remote sessions)
    return vim.env.WEZTERM_PANE ~= nil or (vim.env.TERM and vim.env.TERM:match("wezterm"))
  end,
  opts = {
    debug = false,
    auto_switch = true,
  },
  config = function(_, opts)
    require("ime-helper").setup(opts)
    
    -- LazyVim style loading notification
    vim.notify("WezTerm IME Helper loaded", vim.log.levels.INFO, { title = "Plugin" })
  end,
  keys = {
    -- Using LazyVim UI key prefix <leader>u
    {
      "<leader>uie",
      function()
        require("ime-helper").switch_to_en()
        vim.notify("Switched to English IME", vim.log.levels.INFO, { title = "IME" })
      end,
      desc = "IME: Switch to English",
    },
    {
      "<leader>uii",
      function()
        require("ime-helper").switch_to_ime()
        vim.notify("Switched to Input Method", vim.log.levels.INFO, { title = "IME" })
      end,
      desc = "IME: Switch to Input Method",
    },
    {
      "<leader>uis",
      function()
        require("ime-helper").status()
      end,
      desc = "IME: Show Status",
    },
  }
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "guohao117/noime.nvim",
  config = function()
    -- Plugin will auto-initialize with default settings
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'guohao117/noime.nvim'
```

## Setup

The plugin automatically initializes with default settings when loaded. No manual setup is required.

If you want to customize the behavior, you can call the setup function:

```lua
require('ime-helper').setup({
  -- Custom configuration options can be added here in the future
})
```

## Usage

The plugin works automatically once installed. It will:

1. Switch to English input method when leaving insert mode (`InsertLeave`)
2. Switch to English input method when entering command mode
3. Switch to English input method when entering normal mode from other modes

### Manual Commands

The plugin provides several commands for manual control:

- `:IMESwitchToEN` - Manually switch to English input method
- `:IMESwitchToIME` - Manually switch to IME (input method editor)
- `:IMEStatus` - Show current IME status

### Key Mappings (with lazy.nvim)

When using the recommended lazy.nvim configuration, the following key mappings are available:

- `<leader>uie` - Switch to English input method
- `<leader>uii` - Switch to IME (input method editor)
- `<leader>uis` - Show current IME status

## How It Works

The plugin uses OSC 1337 escape sequences to communicate with WezTerm's ime-helper plugin. This approach allows the plugin to work seamlessly in both local and remote sessions (SSH, etc.) since the escape sequences are passed through to the terminal.

When you leave insert mode, the plugin sends an OSC 1337 sequence that tells WezTerm to switch the input method to English, preventing IME popups from appearing during normal Neovim operations.

## Configuration with WezTerm

Make sure you have the wezterm-ime-helper plugin properly configured in your WezTerm configuration:

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
local config = {}

-- Load the ime-helper plugin
local ime_helper = wezterm.plugin.require("https://github.com/guohao117/wezterm-ime-helper")

-- Configure IME helper
ime_helper.apply_to_config(config, {
  -- Configuration options for wezterm-ime-helper
})

-- Set TERM to include "wezterm" for remote session detection
config.term = "wezterm"

return config
```

### Remote Session Setup

For the plugin to work in remote sessions (SSH), you need to:

1. **Configure WezTerm TERM**: Set `config.term = "wezterm"` in your WezTerm configuration (as shown above)

2. **SSH Configuration**: The `TERM` environment variable will be automatically passed through SSH, allowing the remote Neovim to detect it's running in WezTerm

3. **Tmux Configuration**: If you're using tmux in remote sessions, add this to your `~/.tmux.conf` to allow OSC sequences to pass through:
   ```bash
   # Allow OSC sequences to pass through tmux
   set -g allow-passthrough on
   
   # Alternative for older tmux versions
   # set -ga terminal-overrides ',*:Tc'
   ```

4. **Verify Detection**: On the remote server, you can verify the setup by checking:
   ```bash
   echo $TERM  # Should output "wezterm"
   ```

This approach allows the plugin to work seamlessly in both local and remote sessions by detecting the WezTerm environment through either:
- `WEZTERM_PANE` environment variable (local sessions)
- `TERM` environment variable containing "wezterm" (remote sessions)

The OSC 1337 escape sequences will pass through SSH and tmux (with proper configuration) to reach WezTerm for IME control.

## Troubleshooting

### Plugin not working

1. **Check WezTerm**: Ensure you're running the plugin in WezTerm terminal
2. **Verify ime-helper**: Make sure wezterm-ime-helper plugin is installed and configured
3. **Environment detection**: The plugin loads when either `WEZTERM_PANE` environment variable is present (local) or `TERM` contains "wezterm" (remote sessions)
4. **Tmux passthrough**: If using tmux, ensure `allow-passthrough on` is set in your tmux configuration

### Commands not available

If the commands are not available, the plugin might not have loaded. Check:

- You're running in WezTerm (check `echo $WEZTERM_PANE` or `echo $TERM`)
- The plugin is properly installed
- No errors in `:messages`

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- [wezterm-ime-helper](https://github.com/guohao117/wezterm-ime-helper) - The WezTerm plugin that this Neovim plugin communicates with
- [WezTerm](https://wezfurlong.org/wezterm/) - A powerful cross-platform terminal emulator