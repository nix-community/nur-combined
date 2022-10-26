-- TOP PANEL EXTRA IS VOOR HET EXTRA SCHERM

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

-- import widgets
local task_list = require("widgets.task-list")

-- define module table
local top_panel = {}

local separator = wibox.widget({ type = "textbox", align = "right"})
separator.text = "xxx "

-- ===================================================================
-- Bar Creation
-- ===================================================================

top_panel.create = function(s)
  local panel = awful.wibar({
    screen = s,
    position = "top",
    visible = true,
    ontop = true,
    height = beautiful.top_panel_height,
    width = s.geometry.width,
  })

  panel:setup {
    expand = "none",
    layout = wibox.layout.align.horizontal,
    {
      task_list.create(s),
      layout = wibox.layout.fixed.horizontal,
      --require("widgets.bluetooth"),
      --require("widgets.wifi"),
      --require("widgets.battery"),
    },
    {
      layout = wibox.layout.fixed.horizontal,
    },
    {
      layout = wibox.layout.fixed.horizontal,
      --require("widgets.layout-box"),
      require("widgets.focussed_screen")
    }
  }

  -- hide panel when client is fullscreen
  client.connect_signal('property::fullscreen',
  function(c)
    panel.visible = not c.fullscreen
  end
  )
end

return top_panel
