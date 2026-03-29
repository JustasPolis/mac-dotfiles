local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- ==========================================================================
-- Performance (the whole point of this exercise)
-- ==========================================================================
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 120
config.animation_fps = 120
config.mux_output_parser_coalesce_delay_ms = 0
config.cursor_blink_rate = 0
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.unicode_version = 14
config.enable_kitty_graphics = false
config.use_ime = true
config.status_update_interval = 5000
config.native_macos_fullscreen_mode = true


-- ==========================================================================
-- Font — match Kitty: Fira Code, size 15, 150% line height
-- ==========================================================================
config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium" })
config.font_size = 15.0
config.line_height = 1.5
config.freetype_load_flags = "NO_HINTING"
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- ==========================================================================
-- Window / appearance — minimal, match Kitty
-- ==========================================================================
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = { left = 0, right = 0, top = 4, bottom = 0 }
config.enable_scroll_bar = false
config.adjust_window_size_when_changing_font_size = false
config.hide_mouse_cursor_when_typing = true
config.macos_window_background_blur = 0
config.window_close_confirmation = "NeverPrompt"
config.native_macos_fullscreen_mode = true

-- ==========================================================================
-- Tab bar — minimal, top, match Kitty style
-- ==========================================================================
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- ==========================================================================
-- Colors — match Kitty custom theme
-- ==========================================================================
config.color_scheme = "custom"
config.color_schemes = {
  ["custom"] = {
    foreground = "#c9c7cd",
    background = "#161617",
    cursor_fg = "#161617",
    cursor_bg = "#c9c7cd",
    selection_fg = "#c9c7cd",
    selection_bg = "#353539",

    ansi = {
      "#27272a", -- black
      "#f5a191", -- red
      "#e29eca", -- green (mapped to magenta in your kitty)
      "#e6b99d", -- yellow
      "#aca1cf", -- blue
      "#e29eca", -- magenta
      "#ea83a5", -- cyan
      "#c1c0d4", -- white
    },
    brights = {
      "#353539", -- bright black
      "#ffae9f", -- bright red
      "#ecaad6", -- bright green
      "#f0c5a9", -- bright yellow
      "#b9aeda", -- bright blue
      "#ecaad6", -- bright magenta
      "#f591b2", -- bright cyan
      "#cac9dd", -- bright white
    },

    tab_bar = {
      background = "#161617",
      active_tab = {
        bg_color = "#161617",
        fg_color = "#c9c7cd",
        intensity = "Bold",
      },
      inactive_tab = {
        bg_color = "#161617",
        fg_color = "#353539",
      },
      inactive_tab_hover = {
        bg_color = "#161617",
        fg_color = "#c9c7cd",
      },
    },
  },
}

-- ==========================================================================
-- Tab title format — "index:title" like Kitty
-- ==========================================================================
wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  -- shorten the title if it's too long
  if #title > 24 then
    title = title:sub(1, 24) .. ".."
  end
  local index = tab.tab_index + 1
  return string.format(" %d:%s ", index, title)
end)

-- Status bar git branch removed — causes jank even when cached.
-- Use your fish/starship prompt for git info instead.

-- ==========================================================================
-- Misc behavior
-- ==========================================================================
config.scrollback_lines = 3500
config.default_prog = { "/opt/homebrew/bin/fish" }
config.audible_bell = "Disabled"
config.check_for_updates = false

-- ==========================================================================
-- Keybindings — tmux-style with Ctrl-a as leader
-- ==========================================================================

-- Disable all default key assignments to start clean
config.disable_default_key_bindings = true

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1500 }

config.keys = {
  -- === Pane splits (match tmux) ===
  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- === Pane navigation (Ctrl-a + arrows) ===
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

  -- === Pane resize (Ctrl-a + Ctrl-arrow, like tmux) ===
  { key = "LeftArrow", mods = "LEADER|CTRL", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "RightArrow", mods = "LEADER|CTRL", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "UpArrow", mods = "LEADER|CTRL", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "DownArrow", mods = "LEADER|CTRL", action = act.AdjustPaneSize({ "Down", 5 }) },

  -- === Pane management ===
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },

  -- === Tab management (tmux: windows) ===
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "q", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = ",", mods = "LEADER", action = act.PromptInputLine({
    description = "Rename tab:",
    action = wezterm.action_callback(function(window, _, line)
      if line then
        window:active_tab():set_title(line)
      end
    end),
  })},

  -- === Tab selection by number (1-indexed like your tmux) ===
  { key = "1", mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2", mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3", mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4", mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5", mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6", mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7", mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8", mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9", mods = "LEADER", action = act.ActivateTab(8) },

  -- === Session / detach ===
  { key = "d", mods = "LEADER", action = act.DetachDomain("CurrentPaneDomain") },

  -- === Copy mode (Ctrl-a [ like tmux) ===
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- === Send Ctrl-a to the terminal (double tap, like tmux send-prefix) ===
  { key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },

  -- === Custom: open opencode in new tab (Ctrl-a o) ===
  { key = "o", mods = "LEADER", action = act.SpawnCommandInNewTab({
    args = { "/opt/homebrew/bin/fish", "-c", "opencode" },
  })},

  -- === Standard terminal shortcuts (not behind leader) ===
  { key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },
  { key = "=", mods = "CMD", action = act.IncreaseFontSize },
  { key = "-", mods = "CMD", action = act.DecreaseFontSize },
  { key = "0", mods = "CMD", action = act.ResetFontSize },
  { key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "q", mods = "CMD", action = act.QuitApplication },
  { key = "n", mods = "CMD", action = act.SpawnWindow },
  { key = "Enter", mods = "CMD", action = act.ToggleFullScreen },

  -- === Pass through Ctrl+1..5 like Kitty does (CSI u encoding) ===
  { key = "1", mods = "CTRL", action = act.SendString("\x1b[49;5u") },
  { key = "2", mods = "CTRL", action = act.SendString("\x1b[50;5u") },
  { key = "3", mods = "CTRL", action = act.SendString("\x1b[51;5u") },
  { key = "4", mods = "CTRL", action = act.SendString("\x1b[52;5u") },
  { key = "5", mods = "CTRL", action = act.SendString("\x1b[53;5u") },
  { key = "Enter", mods = "SHIFT", action = act.SendString("\x1b\x0d") },
}

-- === Copy mode vi keybindings (match tmux vi mode) ===
config.key_tables = {
  copy_mode = {
    { key = "Escape", action = act.CopyMode("Close") },
    { key = "q", action = act.CopyMode("Close") },
    { key = "h", action = act.CopyMode("MoveLeft") },
    { key = "j", action = act.CopyMode("MoveDown") },
    { key = "k", action = act.CopyMode("MoveUp") },
    { key = "l", action = act.CopyMode("MoveRight") },
    { key = "w", action = act.CopyMode("MoveForwardWord") },
    { key = "b", action = act.CopyMode("MoveBackwardWord") },
    { key = "e", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "0", action = act.CopyMode("MoveToStartOfLine") },
    { key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "g", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "u", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "d", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "v", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "V", mods = "SHIFT", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "y", action = act.Multiple({
      act.CopyTo("ClipboardAndPrimarySelection"),
      act.CopyMode("Close"),
    })},
    { key = "/", action = act.Search("CurrentSelectionOrEmptyString") },
  },
}

return config
