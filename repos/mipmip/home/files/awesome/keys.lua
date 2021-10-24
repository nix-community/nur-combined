--      ██╗  ██╗███████╗██╗   ██╗███████╗
--      ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝
--      █████╔╝ █████╗   ╚████╔╝ ███████╗
--      ██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║
--      ██║  ██╗███████╗   ██║   ███████║
--      ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝

local debug = require("debug")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local cyclefocus = require('cyclefocus')
local hotkeys_popup = require("awful.hotkeys_popup.widget")

require("awful.hotkeys_popup.keys")

local function debug_something()
  naughty.notify({
    preset = naughty.config.presets.critical,
    title = "Inspect",
    text = gears.debug.dump_return("d",10)
  })
end
--debug_something()

function add_my_helpgroup(helpgroup)
  if helpgroup.rule then
      for group_name, group_data in pairs({
        [helpgroup.group_title] = {
          color = helpgroup.group_color,
          rule_any = helpgroup.rule
        }
      }) do
      hotkeys_popup.add_group_rules(group_name, group_data)
    end
  end
  hotkeys_popup.add_hotkeys(helpgroup.keys)
end

local my_hotkey_help = require("mod_my_hotkey_help")
add_my_helpgroup(my_hotkey_help.vifm)
add_my_helpgroup(my_hotkey_help.readline)
add_my_helpgroup(my_hotkey_help.feh)
add_my_helpgroup(my_hotkey_help.inkscape)

-- Default Applications
local apps = require("apps").default

-- Define mod keys
local modkey = "Mod4"
local altkey = "Mod1"

-- define module table
local keys = {}

local mod_menu = require("mod_menu")
local mod_hotkey_funcs = require("mod_hotkey_funcs")

-- ===================================================================
-- Mouse bindings
-- ===================================================================

-- Mouse buttons on the desktop
keys.desktopbuttons = gears.table.join(
   -- left click on desktop to hide notification
   awful.button({}, 1,
      function ()
         naughty.destroy_all_notifications()
      end
   )
)

-- Mouse buttons on the client
keys.clientbuttons = gears.table.join(
   -- Raise client
   awful.button({}, 1,
      function(c)
         client.focus = c
         c:raise()
      end
   ),

   -- Move and Resize Client
   awful.button({"Control"}, 1, awful.mouse.client.move),
   awful.button({"Control"}, 3, awful.mouse.client.resize)
)

-- ===================================================================
-- Desktop Key bindings
-- ===================================================================

keys.globalkeys = gears.table.join(
   -- =========================================
   -- SPAWN APPLICATION KEY BINDINGS
   -- =========================================

    awful.key({ modkey,    "Shift"   }, "0",      function() awful.spawn("keepassxc") end,                {description = "show keepassxc",       group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "1",      function() awful.spawn(apps.timetracker) end,           {description = "open tempo2",          group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "2",      function() awful.spawn(apps.filebrowser) end,           {description = "open Files(nautilus)", group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "3",      function() awful.spawn(apps.webbrowser) end,            {description = "Webrowser",            group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "4",      function() awful.spawn.with_shell(apps.screenshot) end, {description = "make screenshot",      group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "6",      function() awful.spawn(apps.calculator) end,            {description = "Calculator",           group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "7",      function() awful.spawn(apps.calendar) end,              {description = "Calendar",             group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "8",      function() awful.spawn(apps.email) end,                 {description = "Email",                group = "launcher"}),
    awful.key({ modkey,    "Shift"   }, "9",      function() awful.spawn("telegram-desktop") end,         {description = "show telegram",        group = "launcher"}),
    awful.key({ modkey,    },           "Return", function() awful.spawn(apps.terminal) end,              {description = "open a terminal",      group = "launcher"}),
    awful.key({ modkey,    "Control" }, "Return", function() awful.spawn(apps.filemanagercli) end,        {description = "open vim",             group = "launcher"}),
    awful.key({ modkey,    },           "space",  function() awful.spawn(apps.launcher) end,              {description = "open clipboard",       group = "launcher"}),
    awful.key({ "Mod1",    },           "Tab",    function() awful.spawn(apps.openwindows) end,           {description = "open clipboard",       group = "launcher"}),
    awful.key({ "Control", },           "space",  function() awful.spawn(apps.clipboard) end,             {description = "open clipboard",       group = "plakbord"}),
    awful.key({ modkey,    },           "w",      function() mod_menu:show() end,                         {description = "show main menu",       group = "awesome"}),
    awful.key({ modkey,    },           "Escape", function() awful.spawn(apps.lock) end,                  {description = "lock screen",          group = "hotkeys"}),
    awful.key({ modkey,    },           "s",      hotkeys_popup.show_help,                                {description = "show help",            group = "awesome"}),
    awful.key({ modkey,    },           "F12",    mod_hotkey_funcs.audio_volume_up,                       {description = "volume up",            group = "hotkeys"}),
    awful.key({ modkey,    },           "F11",    mod_hotkey_funcs.audio_volume_down,                     {description = "volume down",          group = "hotkeys"}),

    awful.key({}, "F11", function () mod_hotkey_funcs.toggle_desktop() end, {description = "toggle visibilty of  all windows in current tag", group = "hotkeys"}),

    -- Alt-Tab: cycle through clients on the same screen.
    -- This must be a clientkeys mapping to have source_c available in the callback.
    cyclefocus.key({ modkey, }, "Tab", {
      -- cycle_filters as a function callback:
      -- cycle_filters = { function (c, source_c) return c.screen == source_c.screen end },

      -- cycle_filters from the default filters:
      cycle_filters = { cyclefocus.filters.same_screen, cyclefocus.filters.common_tag },
      keys = {'Tab', 'ISO_Left_Tab'}  -- default, could be left out
    }),

    awful.key({ modkey, "Shift"   }, "z",      function()
      awful.spawn.with_shell("echo '394720393' | xclip")
      awful.spawn("xfce4-popup-clipman")
    end, {description = "paste bank zakelijk", group = "plakbord"}),

    awful.key({ modkey, "Shift"   }, "x",      function()
      awful.spawn.with_shell("echo '374344744' | xclip")
      awful.spawn("xfce4-popup-clipman")
    end, {description = "paste bank prive", group = "plakbord"}),


   -- =========================================
   -- CLIENT FOCUSING
   -- =========================================

   awful.key({modkey}, "j",     mod_hotkey_funcs.focus_bydirection_down,  {description = "focus down", group = "client"}),
   awful.key({modkey}, "k",     mod_hotkey_funcs.focus_bydirection_up,    {description = "focus up",   group = "client"}),
   awful.key({modkey}, "h",     mod_hotkey_funcs.focus_bydirection_left,  {description = "focus up",   group = "client"}),
   awful.key({modkey}, "l",     mod_hotkey_funcs.focus_bydirection_right, {description = "focus up",   group = "client"}),
   awful.key({modkey}, "Down",  mod_hotkey_funcs.focus_bydirection_down,  {description = "focus down", group = "client"}),
   awful.key({modkey}, "Up",    mod_hotkey_funcs.focus_bydirection_up,    {description = "focus up",   group = "client"}),
   awful.key({modkey}, "Left",  mod_hotkey_funcs.focus_bydirection_left,  {description = "focus up",   group = "client"}),
   awful.key({modkey}, "Right", mod_hotkey_funcs.focus_bydirection_right, {description = "focus up",   group = "client"}),

   -- =========================================
   -- CLIENT RESIZING
   -- =========================================

   awful.key({modkey, "Control"}, "Down",  function(c) mod_hotkey_funcs.resize_client(client.focus, "down") end,   {description = "resize client down", group = "client"}),
   awful.key({modkey, "Control"}, "Up",    function(c) mod_hotkey_funcs.resize_client(client.focus, "up") end,       {description = "resize client up", group = "client"}),
   awful.key({modkey, "Control"}, "Left",  function(c) mod_hotkey_funcs.resize_client(client.focus, "left") end,   {description = "resize client left", group = "client"}),
   awful.key({modkey, "Control"}, "Right", function(c) mod_hotkey_funcs.resize_client(client.focus, "right") end, {description = "resize client right", group = "client"}),
   awful.key({modkey, "Control"}, "j",     function(c) mod_hotkey_funcs.resize_client(client.focus, "down") end,   {description = "resize client down", group = "client"}),
   awful.key({modkey, "Control"}, "k",     function(c) mod_hotkey_funcs.resize_client(client.focus, "up") end,       {description = "resize client up", group = "client"}),
   awful.key({modkey, "Control"}, "h",     function(c) mod_hotkey_funcs.resize_client(client.focus, "left") end,   {description = "resize client left", group = "client"}),
   awful.key({modkey, "Control"}, "l",     function(c) mod_hotkey_funcs.resize_client(client.focus, "right") end, {description = "resize client right", group = "client"}),

   -- =========================================
   -- GAP CONTROL
   -- =========================================
   awful.key({modkey, "Shift"}, "minus", function() awful.tag.incgap(5, nil) end, {description = "increment gaps size for the current tag", group = "gaps"}),
   awful.key({modkey, "Shift"}, "=", function() awful.tag.incgap(-5, nil) end, {description = "decrement gap size for the current tag", group = "gaps"}),

   -- Gap control
   -- =========================================
   -- LAYOUT SELECTION
   -- =========================================

   -- select next layout
--   awful.key({modkey}, "space",
--      function()
--         awful.layout.inc(1)
--      end,
--      {description = "select next", group = "layout"}
--   ),
   -- select previous layout
--   awful.key({modkey, "Shift"}, "space",
--      function()
--         awful.layout.inc(-1)
--      end,
--      {description = "select previous", group = "layout"}
--   ),

   -- =========================================
   -- CLIENT MINIMIZATION
   -- =========================================

   -- restore minimized client
   awful.key({modkey, "Shift"}, "n",
      function()
         local c = awful.client.restore()
         -- Focus restored client
         if c then
            client.focus = c
            c:raise()
         end
      end,
      {description = "restore minimized", group = "client"}
   )
)

-- ===================================================================
-- Client Key bindings
-- ===================================================================

keys.clientkeys = gears.table.join(

   awful.key({modkey, "Shift"}, "Down",  function(c) mod_hotkey_funcs.move_client(c, "down") end,   {description = "Move down to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "Up",    function(c) mod_hotkey_funcs.move_client(c, "up") end,       {description = "Move up to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "Left",  function(c) mod_hotkey_funcs.move_client(c, "left") end,   {description = "Move left to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "Right", function(c) mod_hotkey_funcs.move_client(c, "right") end, {description = "Move right to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "j",     function(c) mod_hotkey_funcs.move_client(c, "down") end,   {description = "Move down to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "k",     function(c) mod_hotkey_funcs.move_client(c, "up") end,       {description = "Move up to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "h",     function(c) mod_hotkey_funcs.move_client(c, "left") end,   {description = "Move left to edge or swap by direction", group = "client"}),
   awful.key({modkey, "Shift"}, "l",     function(c) mod_hotkey_funcs.move_client(c, "right") end, {description = "Move right to edge or swap by direction", group = "client"}),

   awful.key({ modkey,           }, "o",         function(c) client.focus:move_to_screen() end, {description = "move to other screen", group = "client"}),
   awful.key({ modkey,           }, "f",       function(c) c.fullscreen = not c.fullscreen end, {description = "toggle fullscreen",    group = "client"}),
   awful.key({ modkey,           }, "q",                              function(c) c:kill() end, {description = "close",                group = "client"}),
   awful.key({ modkey,           }, "n",                    function(c) c.minimized = true end, {description = "minimize",             group = "client"}),
   awful.key({ modkey, "Control" }, "space",                      awful.client.floating.toggle, {description = "toggle floating",      group = "client"}),
   awful.key({ modkey,           }, "t",     function (c) c.ontop = not c.ontop            end, {description = "toggle keep on top",   group = "client"}),

   awful.key({modkey}, "m", function(c)
     c.maximized = false
     local workarea = awful.screen.focused().workarea
     local ystart = workarea.y + beautiful.useless_gap
     local xstart = workarea.x + beautiful.useless_gap
     local mheight = workarea.height - beautiful.useless_gap * 2 - beautiful.border_width * 2
     local mwidth = workarea.width - beautiful.useless_gap * 2 - beautiful.border_width * 2
     c:geometry({x = xstart, y = ystart, width = mwidth, height = mheight})
     c:raise()
   end,
   {description = "maximize floating window", group = "client"}
   )
   )

-- Bind all key numbers to tags
for i = 1, 6 do
   keys.globalkeys = gears.table.join(keys.globalkeys,
      -- Switch to tag
      awful.key({modkey}, "#" .. i + 9,
         function()
            awful.screen.focus(1)
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
               tag:view_only()
            end
         end,
         {description = "view tag #"..i, group = "tag"}
      ),
      -- Move client to tag
      awful.key({modkey, "Control"}, "#" .. i + 9,
         function()
            if client.focus then
               local tag = client.focus.screen.tags[i]
               if tag then
                  client.focus:move_to_tag(tag)
               end
            end
         end,
         {description = "move focused client to tag #"..i, group = "tag"}
      )
   )
end

return keys
