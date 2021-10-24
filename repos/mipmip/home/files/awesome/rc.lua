--       █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗
--      ██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝
--      ███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗
--      ██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝
--      ██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗
--      ╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================

desktop_apps_minimized = false

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

local naughty = require("naughty")
local debug = require("debug")


-- Import theme
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")
local nice = require("nice")
nice()

-- Import Keybinds
local keys = require("keys")
root.keys(keys.globalkeys)
root.buttons(keys.desktopbuttons)

-- Import rules
local create_rules = require("rules").create
awful.rules.rules = create_rules(keys.clientkeys, keys.clientbuttons)



-- Import notification appearance
require("components.notifications")

-- Import components
--require("components.wallpaper")
require("components.wallpaper_random")
require("components.titlebars")
require("components.exit-screen")
require("components.volume-adjust")


-- Autostart specified apps
local apps = require("apps")
apps.autostart()

-- ===================================================================
-- Set Up Screen & Connect Signals
-- ===================================================================

-- Define tag layouts
awful.layout.layouts = {
   awful.layout.suit.floating,
   awful.layout.suit.tile,
}

-- Import tag settings
local tags = require("tags")

-- Import panels
local top_panel = require("components.top-panel")
local top_panel_extra = require("components.top-panel-extra")

-- Set up each screen (add tags & panels)
local screen_counter = 0
local screen_count = screen:count()
local primary_screen = 1

if screen_count == 2 then
  primary_screen = 1
else
  primary_screen = 1
end

awful.screen.connect_for_each_screen(function(s)

  screen_counter = screen_counter + 1

  for i, tag in pairs(tags) do

    awful.tag.add(i, {
      icon = tag.icon,
      icon_only = true,
      layout = awful.layout.layouts[tag.layout],
      screen = s,
      selected = i == 1
    })

    if screen_counter ~= primary_screen then
      break
    end
  end

  if screen_counter == primary_screen then
    top_panel.create(s)
  else
    top_panel_extra.create(s)
  end

end)

-- remove gaps if layout is set to max
tag.connect_signal('property::layout', function(t)
   local current_layout = awful.tag.getproperty(t, 'layout')
   if (current_layout == awful.layout.suit.max) then
      t.gap = 0
   else
      t.gap = beautiful.useless_gap
   end
end)

-- Signal function to execute when a new client appears.
client.connect_signal("unmanage", function (c)
  -- fix hiding panels when killing fullscreen client
  if(c.fullscreen) then
    c.fullscreen = false
  end

end)

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
   -- Set the window as a slave (put it at the end of others instead of setting it as master)
   if not awesome.startup then
      awful.client.setslave(c)

   end

   if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
   end

   -- fix: new clients on floating layout need to explicitly set floating
   local t = c.first_tag or nil
   local current_layout = awful.tag.getproperty(t, 'layout')

   if (current_layout == awful.layout.suit.floating) then
      c.floating = true
      c.border_width = 0
   end
--   naughty.notify({
     --preset = naughty.config.presets.critical,
     --title = "Inspect",
     --text = gears.debug.dump_return(c.class,"d",10)
--   })

end)



-- ===================================================================
-- Client Focusing
-- ===================================================================


-- Autofocus a new client when previously focused one is closed
require("awful.autofocus")

-- Focus clients under mouse
client.connect_signal("mouse::enter", function(c)
--   c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c)
  floating = awful.client.floating.get(c)

--  naughty.notify({
--    preset = naughty.config.presets.critical,
--    title = "Inspect",
--    text = gears.debug.dump_return(floating,"d",10)
--  })


  if c.class == "Nemo-desktop" then
    c.border_width = 0
  else
    if floating then
      c.border_width = 0--beautiful.border_width
    else
      c.border_color = beautiful.border_focus
      c.border_width = dpi(1)
    end
  end


end)

client.connect_signal("unfocus", function(c)

  floating = awful.client.floating.get(c)
  if floating then
    c.border_width = 0--beautiful.border_width
  else
    c.border_color = beautiful.border_normal
    c.border_width = dpi(1)
  end
end)


-- ===================================================================
-- Garbage collection (allows for lower memory consumption)
-- ===================================================================

collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)

--require("components.pimdock")
