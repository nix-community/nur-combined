local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

-- Set up each screen (add tags & panels)
local screen_counter = 0
local primary_screen = 1
local fancylist

awful.screen.connect_for_each_screen(function(s)

  screen_counter = screen_counter + 1

  if screen_counter == primary_screen then
    local fancy_taglist = require("widgets.fancy_taglist")
    fancylist = fancy_taglist.new({ screen = s })

    local panel = awful.wibar({
      screen = s,
      bg = '#ffff0000', --tranparent
      position = "bottom",
      visible = true,
      ontop = true,
      height = dpi(40),
    })

    panel:setup {
      fancylist,
      expand = "none",
      layout = wibox.container.place,
      valigh = 'center',
    }

    -- hide panel when client is fullscreen
    client.connect_signal('property::fullscreen',
    function(c)
      panel.visible = not c.fullscreen
    end
    )

  end
end)
