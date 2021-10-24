--      ██████╗ ██╗   ██╗██╗     ███████╗███████╗
--      ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
--      ██████╔╝██║   ██║██║     █████╗  ███████╗
--      ██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
--      ██║  ██║╚██████╔╝███████╗███████╗███████║
--      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- define screen height and width
local screen_height = awful.screen.focused().geometry.height
local screen_width = awful.screen.focused().geometry.width

-- define module table
local rules = {}


-- ===================================================================
-- Rules
-- ===================================================================


-- return a table of client rules including provided keys / buttons
function rules.create(clientkeys, clientbuttons)
   return {
      -- All clients will match this rule.
      {
         rule = {},
         properties = {
--            border_width = beautiful.border_width,
--            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered

         },
      },
      -- Floating clients.
      {
         rule_any = {
            instance = {
               "DTA",
               "copyq",
               "gnome-calculator",
            },
            class = {
               "KeePassXC"
            },
            name = {
               "Event Tester",
               "Steam Guard - Computer Authorization Required"
            },
            role = {
               "pop-up",
               "GtkFileChooserDialog"
            },
            type = {
               "dialog"
            }
         }, properties = {floating = true}
      },

      -- Fullscreen clients
      {
         rule_any = {
            class = {
               "Nemo-desktop",
               "nemo-desktop",
            },
         }, properties = {
           focusable = false,
           fullscreen = true,
           sticky = true,
           border_width = dpi(0),
           border_focus_width = dpi(0),
           border_color = "#ffffff00",
           border_focus_olor = "#ffffff00",
           floating = false,
           maximized_horizontal = true,
           maximized_vertical = true,
           ontop = false,
           skip_taskbar = true,
           below = true,
           screen = 1
           --focusable = false,
           --height = screen_height * 0.40,
           --opacity = 0.6

         }
      },
      {
        rule = { class = "timenaut" },
        properties = { floating = true, sticky = true, ontop = true, modal = true },
        screen = awful.screen.focused,
      },

      -- Visualizer
      {
         rule_any = {name = {"cava"}},
         properties = {
            floating = true,
            maximized_horizontal = true,
            sticky = true,
            ontop = false,
            skip_taskbar = true,
            below = true,
            focusable = false,
            height = screen_height * 0.40,
            opacity = 0.6
         },
         callback = function (c)
            decorations.hide(c)
            awful.placement.bottom(c)
         end
      },

      -- Rofi
      {
         rule_any = {name = {"rofi"}},
         properties = {maximized = true, ontop = true}
      },
      -- poppygo
      {
         rule_any = {class = {"poppygo"}},
         --properties = { floating = true },
      },

      -- File chooser dialog
      {
         rule_any = {role = {"GtkFileChooserDialog"}},
         properties = {floating = true, width = screen_width * 0.55, height = screen_height * 0.65}
      },

      -- Pavucontrol & Bluetooth Devices
      {
         rule_any = {class = {"Pavucontrol"}, name = {"Bluetooth Devices"}},
         properties = {floating = true, width = screen_width * 0.55, height = screen_height * 0.45}
      },
   }
end

-- return module table
return rules
