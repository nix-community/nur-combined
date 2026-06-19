-- config docs: <repo:wezterm/wezterm:docs/config/>
-- config docs: <https://wezterm.org/config/files.html>
-- default key assignments: <https://wezterm.org/config/default-keys.html>

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font_size = 14 -- TODO: plumb the same way i do alacritty
config.adjust_window_size_when_changing_font_size = false
config.window_close_confirmation = 'NeverPrompt'
config.alternate_buffer_wheel_scroll_speed = 1  -- reduce scroll speed in neovim. default is 3.
config.selection_word_boundary = ",│`|:\"' ()[]{}<>\t\n‘’“”«»"
-- <https://wezterm.org/config/lua/config/window_padding.html>
config.window_padding = {
  left = 3,
  right = 3,
  -- top is flush with desktop bar and that's OK.
  top = 0,
  -- in practice the bottom already has padding: unless we force an integer number of cells, programs will avoid writing the bottom partial cell.
  bottom = 0,
}

-- required for Pi to receive Ctrl+Shift+P event.
-- allegedly xterm uses an escape sequence to send this event, which not all TUIs handle.
config.enable_kitty_keyboard = true

-- black text on a white background
config.colors = {
  foreground = '#000000',
  background = '#ffffff',
  cursor_bg = '#000000',
  cursor_fg = '#ffffff',
  cursor_border = '#000000',
  selection_fg = '#ffffff',
  selection_bg = '#000000',
  scrollbar_thumb = '#808080',
  split = '#808080',
  ansi = {
    '#000000', -- black
    '#990000', -- red
    '#006600', -- green
    '#996600', -- yellow
    '#0000cc', -- blue
    '#660066', -- purple
    '#006666', -- cyan
    '#cccccc', -- white
  },
  brights = {
    '#666666', -- bright black
    '#cc0000', -- bright red
    '#008800', -- bright green
    '#cc8800', -- bright yellow
    '#0000ff', -- bright blue
    '#880088', -- bright purple
    '#008888', -- bright cyan
    '#ffffff', -- bright white
  },
}

-- disable wezterm's tab bar in favor of native windowing
config.enable_tab_bar = false

-- simpler to drop upstream defaults and define ALL key bindings explicitly.
-- recreated from `wezterm show-keys --lua` and then modified.
config.disable_default_key_bindings = true
local act = wezterm.action
config.keys = {
  -- { key = 'Enter', mods = 'ALT', action = act.ToggleFullScreen },

  -- clipboard
  { key = 'C', mods = 'CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'C', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'c', mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
  { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
  { key = 'V', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'V', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'v', mods = 'SHIFT|CTRL', action = act.PasteFrom 'Clipboard' },
  { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
  { key = 'Copy', mods = 'NONE', action = act.CopyTo 'Clipboard' },
  { key = 'Paste', mods = 'NONE', action = act.PasteFrom 'Clipboard' },
  { key = 'Insert', mods = 'CTRL', action = act.CopyTo 'PrimarySelection' },
  { key = 'Insert', mods = 'SHIFT', action = act.PasteFrom 'PrimarySelection' },

  -- windows/application
  -- { key = 'M', mods = 'CTRL', action = act.Hide },
  -- { key = 'M', mods = 'SHIFT|CTRL', action = act.Hide },
  -- { key = 'm', mods = 'SHIFT|CTRL', action = act.Hide },
  -- { key = 'm', mods = 'SUPER', action = act.Hide },
  { key = 'N', mods = 'CTRL', action = act.SpawnWindow },
  { key = 'N', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
  { key = 'n', mods = 'CTRL', action = act.SpawnWindow },
  { key = 'n', mods = 'SHIFT|CTRL', action = act.SpawnWindow },
  { key = 'n', mods = 'SUPER', action = act.SpawnWindow },

  -- font size
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '-', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
  { key = '-', mods = 'SUPER', action = act.DecreaseFontSize },
  { key = '_', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '_', mods = 'SHIFT|CTRL', action = act.DecreaseFontSize },
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '=', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
  { key = '=', mods = 'SUPER', action = act.IncreaseFontSize },
  { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '+', mods = 'SHIFT|CTRL', action = act.IncreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },
  { key = '0', mods = 'SHIFT|CTRL', action = act.ResetFontSize },
  { key = '0', mods = 'SUPER', action = act.ResetFontSize },
  { key = ')', mods = 'CTRL', action = act.ResetFontSize },
  { key = ')', mods = 'SHIFT|CTRL', action = act.ResetFontSize },

  -- scrollback
  { key = 'PageUp', mods = 'SHIFT', action = act.ScrollByPage(-1) },
  { key = 'PageUp', mods = 'CTRL', action = act.ScrollByPage(-1) },
  { key = 'PageDown', mods = 'SHIFT', action = act.ScrollByPage(1) },
  { key = 'PageDown', mods = 'CTRL', action = act.ScrollByPage(1) },

  -- search/copy mode/quick select
  { key = 'F', mods = 'CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'F', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'f', mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'f', mods = 'SUPER', action = act.Search 'CurrentSelectionOrEmptyString' },
  { key = 'X', mods = 'CTRL', action = act.ActivateCopyMode },
  { key = 'X', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
  { key = 'x', mods = 'SHIFT|CTRL', action = act.ActivateCopyMode },
  { key = 'phys:Space', mods = 'SHIFT|CTRL', action = act.QuickSelect },

  -- configuration/debug/special input
  { key = 'R', mods = 'CTRL', action = act.ReloadConfiguration },
  { key = 'R', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
  { key = 'r', mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
  { key = 'r', mods = 'SUPER', action = act.ReloadConfiguration },
  { key = 'L', mods = 'CTRL', action = act.ShowDebugOverlay },
  { key = 'L', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
  { key = 'l', mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
  { key = 'U', mods = 'CTRL', action = act.CharSelect{ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' } },
  { key = 'U', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' } },
  { key = 'u', mods = 'SHIFT|CTRL', action = act.CharSelect{ copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' } },
  { key = 'K', mods = 'CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  { key = 'K', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  { key = 'k', mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
  { key = 'k', mods = 'SUPER', action = act.ClearScrollback 'ScrollbackOnly' },

  -- panes
  { key = 'Z', mods = 'CTRL', action = act.TogglePaneZoomState },
  { key = 'Z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
  { key = 'z', mods = 'SHIFT|CTRL', action = act.TogglePaneZoomState },
  { key = 'LeftArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
  { key = 'LeftArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Left', 1 } },
  { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
  { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Right', 1 } },
  { key = 'UpArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
  { key = 'UpArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Up', 1 } },
  { key = 'DownArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
  { key = 'DownArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize{ 'Down', 1 } },
  { key = '"', mods = 'ALT|CTRL', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
  { key = '"', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
  { key = '\'', mods = 'SHIFT|ALT|CTRL', action = act.SplitVertical{ domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'ALT|CTRL', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  { key = '%', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
  { key = '5', mods = 'SHIFT|ALT|CTRL', action = act.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
}

-- config.key_tables = {
--   copy_mode = {
--     { key = 'Tab', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'Tab', mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'Enter', mods = 'NONE', action = act.CopyMode 'MoveToStartOfNextLine' },
--     { key = 'Escape', mods = 'NONE', action = act.Multiple{ 'ScrollToBottom', { CopyMode = 'Close' } } },
--     { key = 'Space', mods = 'NONE', action = act.CopyMode{ SetSelectionMode = 'Cell' } },
--     { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = '$', mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = ',', mods = 'NONE', action = act.CopyMode 'JumpReverse' },
--     { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
--     { key = ';', mods = 'NONE', action = act.CopyMode 'JumpAgain' },
--     { key = 'F', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
--     { key = 'F', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = false } } },
--     { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
--     { key = 'G', mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
--     { key = 'H', mods = 'NONE', action = act.CopyMode 'MoveToViewportTop' },
--     { key = 'H', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
--     { key = 'L', mods = 'NONE', action = act.CopyMode 'MoveToViewportBottom' },
--     { key = 'L', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
--     { key = 'M', mods = 'NONE', action = act.CopyMode 'MoveToViewportMiddle' },
--     { key = 'M', mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
--     { key = 'O', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
--     { key = 'O', mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
--     { key = 'T', mods = 'NONE', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
--     { key = 'T', mods = 'SHIFT', action = act.CopyMode{ JumpBackward = { prev_char = true } } },
--     { key = 'V', mods = 'NONE', action = act.CopyMode{ SetSelectionMode = 'Line' } },
--     { key = 'V', mods = 'SHIFT', action = act.CopyMode{ SetSelectionMode = 'Line' } },
--     { key = '^', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = '^', mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'b', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'b', mods = 'CTRL', action = act.CopyMode 'PageUp' },
--     { key = 'c', mods = 'CTRL', action = act.Multiple{ 'ScrollToBottom', { CopyMode = 'Close' } } },
--     { key = 'd', mods = 'CTRL', action = act.CopyMode{ MoveByPage = 0.5 } },
--     { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
--     { key = 'f', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = false } } },
--     { key = 'f', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'f', mods = 'CTRL', action = act.CopyMode 'PageDown' },
--     { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
--     { key = 'g', mods = 'CTRL', action = act.Multiple{ 'ScrollToBottom', { CopyMode = 'Close' } } },
--     { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
--     { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
--     { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
--     { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
--     { key = 'm', mods = 'ALT', action = act.CopyMode 'MoveToStartOfLineContent' },
--     { key = 'o', mods = 'NONE', action = act.CopyMode 'MoveToSelectionOtherEnd' },
--     { key = 'q', mods = 'NONE', action = act.Multiple{ 'ScrollToBottom', { CopyMode = 'Close' } } },
--     { key = 't', mods = 'NONE', action = act.CopyMode{ JumpForward = { prev_char = true } } },
--     { key = 'u', mods = 'CTRL', action = act.CopyMode{ MoveByPage = -0.5 } },
--     { key = 'v', mods = 'NONE', action = act.CopyMode{ SetSelectionMode = 'Cell' } },
--     { key = 'v', mods = 'CTRL', action = act.CopyMode{ SetSelectionMode = 'Block' } },
--     { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'y', mods = 'NONE', action = act.Multiple{ { CopyTo = 'ClipboardAndPrimarySelection' }, { Multiple = { 'ScrollToBottom', { CopyMode = 'Close' } } } } },
--     { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PageUp' },
--     { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'PageDown' },
--     { key = 'End', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
--     { key = 'Home', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
--     { key = 'LeftArrow', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
--     { key = 'LeftArrow', mods = 'ALT', action = act.CopyMode 'MoveBackwardWord' },
--     { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
--     { key = 'RightArrow', mods = 'ALT', action = act.CopyMode 'MoveForwardWord' },
--     { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'MoveUp' },
--     { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'MoveDown' },
--   },
-- 
--   search_mode = {
--     { key = 'Enter', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
--     { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
--     { key = 'n', mods = 'CTRL', action = act.CopyMode 'NextMatch' },
--     { key = 'p', mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
--     { key = 'r', mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
--     { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
--     { key = 'PageUp', mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
--     { key = 'PageDown', mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
--     { key = 'UpArrow', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
--     { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
--   },
-- }

-- when clicking a file:// hyperlink, cd into directories in the shell
-- instead of opening them in the OS file manager.
-- adapted from: <https://wezterm.org/recipes/hyperlinks.html#configuration>
wezterm.on('open-uri', function(window, pane, uri)
  if not uri:match('^file://') then
    -- not a file:// URI -> let the default handler open it
    return
  end

  -- don't inject commands when the terminal is in an alt screen (vim, less, etc.)
  if pane:is_alt_screen_active() then
    return
  end

  local url = wezterm.url.parse(uri)
  local file_path = url.file_path
  if not file_path then
    return
  end

  local success, stdout = wezterm.run_child_process {
    'file', '--brief', '--mime-type', file_path,
  }

  if success and stdout:match('^inode/directory') then
    -- directory: cd into it and re-list via eza
    pane:send_text('c ' .. wezterm.shell_join_args { file_path } .. '\r')
    return false -- suppress default (OS file opener) behavior
  end

  -- not a directory; let the default handler take over
end)

return config
