
-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local tag_list = require("widgets.tag-list")
-- import widgets
local task_list = require("widgets.task-list")

-- define module table
local top_panel = {}

-- Set up each screen (add tags & panels)
local screen_counter = 0
local primary_screen = 1
local fancylist

awful.screen.connect_for_each_screen(function(s)

  screen_counter = screen_counter + 1

  if screen_counter == primary_screen then
    local fancy_taglist = require("widgets.fancy_taglist")
    fancylist = fancy_taglist.new({ screen = s })

  end
end)

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
      xbg = "#ffffff00"
   })

   panel:setup {
      expand = "none",
      layout = wibox.layout.align.horizontal,
      {
        fancylist,
        --tag_list.create(s),
        layout = wibox.layout.fixed.horizontal,
        expand = "outside"
        --require("widgets.bluetooth"),
        --require("widgets.wifi"),
        --require("widgets.battery"),
      },
    {
      task_list.create(s),
      layout = wibox.layout.fixed.horizontal,
    },
      {
      layout = wibox.layout.fixed.horizontal,
        wibox.layout.margin(wibox.widget.systray(), 0, 0, 3, 3),
        require("widgets.calendar"),
        require("widgets.layout-box"),
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
