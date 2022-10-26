local awful = require("awful")
local beautiful = require("beautiful")
local apps = require("apps").default

local mod_menu = {}

local myawesomemenu = {
  { "restart", awesome.restart },
  { "nemo", function()
    awful.spawn("nemo-desktop")
  end},
  { "nemof", function()

    local all_clients = client.get()
    for i, c in pairs(all_clients) do
      if c.class == "Nemo-desktop" then
        client.focus = c
      end
    end

  end},
  { "quit", function() awesome.quit() end}
}


local clipb = {
  { "bank zakelijk", function()
      awful.spawn.with_shell("echo '394720393' | xclip")
--      awful.spawn("xfce4-popup-clipman")
  end},
  { "bank prive", function()
      awful.spawn.with_shell("echo '374344744' | xclip")
--      awful.spawn("xfce4-popup-clipman")
  end},
}
local myxrandr = {
  { "Staan", function()
    awful.spawn.with_shell("~/.screenlayout/ojs-serre-staan.sh")
    awesome.restart()
  end},
  { "Zitten", function()
    awful.spawn.with_shell("~/.screenlayout/ojs-serre-zitten.sh")
    awesome.restart()
  end},
}

local menu_awesome  = { "awesome",  myawesomemenu, beautiful.awesome_icon }
local menu_xrandr   = { "randr",         myxrandr, beautiful.awesome_icon }
local menu_clipb   = { "clipboard",         clipb, beautiful.awesome_icon }
local menu_terminal = { "open terminal", apps.terminal }

main_menu = awful.menu({
  items = {
    menu_awesome,
    menu_xrandr,
    menu_clipb,
    menu_terminal,
  }
})

return main_menu
