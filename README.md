# Ghostty Terminal Configuration

This repository contains the configuration for [Ghostty](https://ghostty.org/), a fast, feature-rich, and cross-platform terminal emulator.

## Configuration Overview

### Tmux Integration

The configuration includes custom keybindings for seamless tmux integration:

- **`cmd+s`** - Send tmux save-buffer command (`\x01\x73`)
  - Saves the current tmux buffer to a file

- **`cmd+b`** - Toggle zoom on current tmux pane (`\x01\x7a`)
  - Maximizes/restores the current pane in tmux

### Aesthetics

The visual appearance is configured with a modern, translucent look:

- **Background Opacity**: `0.95` - Slightly transparent background for a sleek appearance
- **Background Blur**: `16` - Adds blur effect to content behind the terminal window
- **Background Color**: `#000000` - Pure black background
- **Titlebar Style**: `hidden` - Hides the macOS titlebar for a more immersive experience

### Typography

Font settings optimized for readability:

- **Font Size**: `16` - Comfortable reading size
- **Font Thickening**: Enabled with strength `1` - Makes text slightly bolder for better visibility
- **Cell Height Adjustment**: `1` - Increases line spacing for improved readability

## File Structure

```
.
├── config         # Main Ghostty configuration file
└── README.md      # This file
```

## Usage

This configuration is automatically loaded by Ghostty when placed in `~/.config/ghostty/`.

To modify the configuration:
1. Edit the `config` file
2. Restart Ghostty or reload the configuration for changes to take effect

## Requirements

- [Ghostty terminal emulator](https://ghostty.org/)
- macOS (for titlebar and keybinding settings)
- tmux (optional, for tmux integration features)

## Customization

To customize this configuration:

1. **Change opacity**: Adjust `background-opacity` (0.0 - 1.0)
2. **Modify keybindings**: Update `keybind` entries with your preferred shortcuts
3. **Adjust font size**: Change `font-size` to your preference
4. **Disable blur**: Remove or comment out `background-blur` line

## Notes

- The tmux keybindings assume the default tmux prefix key (`Ctrl+b` represented as `\x01`)
- The hidden titlebar provides more screen space but removes native window controls
- Font thickening may vary in appearance depending on the font family used
