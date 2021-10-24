--      ██╗     ███████╗███████╗████████╗    ██████╗  █████╗ ███╗   ██╗███████╗██╗
--      ██║     ██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
--      ██║     █████╗  █████╗     ██║       ██████╔╝███████║██╔██╗ ██║█████╗  ██║
--      ██║     ██╔══╝  ██╔══╝     ██║       ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
--      ███████╗███████╗██║        ██║       ██║     ██║  ██║██║ ╚████║███████╗███████╗
--      ╚══════╝╚══════╝╚═╝        ╚═╝       ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local beautiful = require("beautiful")
local wibox = require("wibox")
local dpi = beautiful.xresources.apply_dpi
local awful = require("awful")
local gears = require("gears")

local tag_list = require("widgets.tag-list")
local folder = require("widgets.folder")

local home_dir = os.getenv("HOME")

-- define module table
local tags_panel = {}

-- ===================================================================
-- Bar Creation
-- ===================================================================

tags_panel.create = function(s)

   local panel_shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, true, true, false, 12)
   end
   local maximized_panel_shape = function(cr, width, height)
      gears.shape.rectangle(cr, width, height)
   end

   if beautiful.tags_panel_position == "top" or beautiful.tags_panel_position == "bottom" then
     separator = require("widgets.vertical-separator")
     panel_width = s.geometry.width * 7/10
     panel_height = beautiful.tags_panel_width
     panel_layout_align = wibox.layout.align.horizontal
     panel_layout_fixed = wibox.layout.fixed.horizontal
   else
     separator = require("widgets.horizontal-separator")
     panel_height = s.geometry.height * 7/10
     panel_height = 800
     panel_width = beautiful.tags_panel_width
     panel_layout_align = wibox.layout.align.vertical
     panel_layout_fixed = wibox.layout.fixed.vertical
   end

   panel = awful.wibar({
      screen = s,
      position = beautiful.tags_panel_position,
      height = panel_height,
      width = panel_width,
      ontop = true,
      shape = panel_shape
   })

   panel:setup {
      expand = "none",
      layout = panel_layout_align,
      nil,
      {
         layout = panel_layout_fixed,
         -- add taglist widget
         tag_list.create(s),
         -- add folders widgets
--         {
            --separator,
            --folder.create(home_dir),
            --folder.create(home_dir .. "/Documents"),
            --folder.create(home_dir .. "/Downloads"),
            --separator,
            --folder.create("trash://"),
            --layout = panel_layout_fixed
         --}
      },
      nil
   }

   -- panel background that becomes visible when client is maximized
   panel_bg = wibox({
      screen = s,
      position = beautiful.tags_panel_position,
      height = panel_height,
      width = panel_width,
      visible = false
   })


   -- ===================================================================
   -- Functionality
   -- ===================================================================


   -- hide panel when client is fullscreen
   client.connect_signal("property::fullscreen",
      function(c)
         panel.visible = not c.fullscreen
      end
   )

   -- maximize panel if client is maximized
   local function toggle_maximize_tags_panel(is_maximized)
      panel_bg.visible = is_maximized
      if is_maximized then
         panel.shape = maximized_panel_shape
      else
         panel.shape = panel_shape
      end
   end

   -- maximize if a client is maximized
   client.connect_signal("property::maximized", function(c)
      toggle_maximize_tags_panel(c.maximized)
   end)

   client.connect_signal("manage", function(c)
      if awful.tag.getproperty(c.first_tag, "layout") == awful.layout.suit.max then
         toggle_maximize_tags_panel(true)
      end
   end)

   -- unmaximize if a client is removed and there are no maximized clients left
   client.connect_signal("unmanage", function(c)
      local t = awful.screen.focused().selected_tag
      -- if client was maximized
      if c.maximized then
         -- check if any clients that are open are maximized
         for _, c in pairs(t:clients()) do
            if c.maximized then
               return
            end
         end
         toggle_maximize_tags_panel(false)

      -- if tag was maximized
      elseif awful.tag.getproperty(t, "layout") == awful.layout.suit.max then
         -- check if any clients are open (and therefore maximized)
         for _ in pairs(t:clients()) do
            return
         end
         toggle_maximize_tags_panel(false)
      end
   end)

   -- maximize if layout is maximized and a client is in the layout
   tag.connect_signal("property::layout", function(t)
      -- check if layout is maximized
      if (awful.tag.getproperty(t, "layout") == awful.layout.suit.max) then
         -- check if clients are open
         for _ in pairs(t:clients()) do
            toggle_maximize_tags_panel(true)
            return
         end
         toggle_maximize_tags_panel(false)
      else
         toggle_maximize_tags_panel(false)
      end
   end)

   -- maximize if a tag is swapped to with a maximized client
   tag.connect_signal("property::selected", function(t)
      -- check if layout is maximized
      if (awful.tag.getproperty(t, "layout") == awful.layout.suit.max) then
         -- check if clients are open
         for _ in pairs(t:clients()) do
            toggle_maximize_tags_panel(true)
            return
         end
         toggle_maximize_tags_panel(false)
      else
         -- check if any clients that are open are maximized
         for _, c in pairs(t:clients()) do
            if c.maximized then
               toggle_maximize_tags_panel(true)
               return
            end
         end
         toggle_maximize_tags_panel(false)
      end
   end)
end

return tags_panel
