
-- ===================================================================
-- Initialization
-- ===================================================================


local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- define module table
local theme = {}


-- ===================================================================
-- Theme Variables
-- ===================================================================

-- Font
theme.font = "SF Pro Text 10"
theme.title_font = "SF Pro Display Medium 10"

-- Background
theme.bg_normal = "#e4e4e4"
--theme.bg_normal = "#444444"
theme.bg_dark = "#000000"
theme.bg_focus = "#e91e63"
theme.bg_urgent = "#e91e63"
theme.bg_minimize = "#fff"
theme.bg_systray = theme.fg_normal
theme.bg_task_normal = "#444444"

-- Foreground
theme.fg_normal = "#444444"
theme.fg_focus = "#000000"
theme.fg_urgent = "#444444"
theme.fg_minimize = "#444444"

-- Window Gap Distance
theme.useless_gap = dpi(7)

-- Show Gaps if Only One Client is Visible
theme.gap_single_client = true

-- Window Borders
theme.border_width = dpi(0)
theme.border_normal = theme.fg_normal
theme.border_focus = "#0099CC"
theme.border_focus_width = dpi(0)

theme.border_marked = theme.fg_urgent

-- Taglist
theme.taglist_bg_empty = "#ffffff00"
theme.taglist_bg_occupied = "#ffffff00"
theme.taglist_bg_urgent = "#e91e63"
theme.taglist_bg_focus = "#e91e63"

-- Tasklist
theme.tasklist_font = theme.font

theme.tasklist_bg_normal = theme.bg_normal
theme.tasklist_bg_focus = theme.bg_focus
theme.tasklist_bg_urgent = theme.bg_urgent

theme.tasklist_fg_focus = theme.fg_focus
theme.tasklist_fg_urgent = theme.fg_urgent
theme.tasklist_fg_normal = theme.fg_normal

-- Panel Sizing
theme.left_panel_width = dpi(55)
theme.tags_panel_width = dpi(55)
theme.tags_panel_position = "top"

theme.top_panel_height = dpi(30)

-- Notification Sizing
theme.notification_max_width = dpi(350)

theme.hotkeys_modifiers_fg = "#e91e6399"


-- ===================================================================
-- Icons
-- ===================================================================


-- You can use your own layout icons like this:
theme.layout_tile = "~/.config/awesome/icons/layouts/view-quilt.png"
theme.layout_floating = "~/.config/awesome/icons/layouts/view-float.png"
theme.layout_max = "~/.config/awesome/icons/layouts/arrow-expand-all.png"

theme.icon_theme = "Tela-light"

-- return theme
return theme
