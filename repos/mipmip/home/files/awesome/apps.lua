--       █████╗ ██████╗ ██████╗ ███████╗
--      ██╔══██╗██╔══██╗██╔══██╗██╔════╝
--      ███████║██████╔╝██████╔╝███████╗
--      ██╔══██║██╔═══╝ ██╔═══╝ ╚════██║
--      ██║  ██║██║     ██║     ███████║
--      ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝


-- ===================================================================
-- Initialization
-- ===================================================================

local awful = require("awful")
local filesystem = require("gears.filesystem")

-- define module table
local apps = {}

-- ===================================================================
-- App Declarations
-- ===================================================================

-- define default apps
apps.default      = {
   terminal       = "alacritty",
   editor         = "alacritty -e vim",
   launcher       = "rofi -modi drun -show drun -width 90 -height 40 -lines 3 -columns 4",
   openwindows    = "rofi -modi drun -show window -width 90 -height 40 -lines 3 -columns 4",
   lock           = "i3lock",
   webbrowser     = "firefox",
   screenshot     = "/usr/local/bin/gnome-screenshot -a",
   clipboard      = "xfce4-popup-clipman",
   filebrowser    = "nemo",
   email          = "evolution",
   filemanagercli = "alacritty -e vifmrun",
   timetracker    = "/home/pim/cTempo2/timenout2tempo/dist_electron/Timenaut-latest.AppImage",
   calculator     = "gnome-calculator",
   calendar       = "gnome-calendar",
}

-- List of apps to start once on start-up
local run_on_start_up = {
   --"/usr/bin/syncthing -no-browser",
   --"/usr/bin/synology-drive",
   --"nohup /usr/bin/telegram-desktop",
   "picom",
   "xfce4-clipman",
   "pasystray",
   "keepassxc",
   "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
   "setxkbmap -option compose:caps",
   "/usr/bin/nextcloud",
   "unclutter"
}

-- start nemo desktop
--awful.spawn("nohup nemo-desktop")
local all_clients = client.get()
for i, c in pairs(all_clients) do
  if (c.class == "nemo-desktop") then
    client.focus = c
  end
  if (c.class == "Nemo-desktop") then
    client.focus = c
  end
end



-- ===================================================================
-- Functionality
-- ===================================================================

-- Run all the apps listed in run_on_start_up
function apps.autostart()
   for _, app in ipairs(run_on_start_up) do
      local findme = app
      local firstspace = app:find(" ")
      if firstspace then
         findme = app:sub(0, firstspace - 1)
      end
         awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, app), false)
   end
end

return apps
