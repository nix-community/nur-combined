local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Add a titlebar if titlebars_enabled is set to true in the rules.
--client.connect_signal("request::titlebars", function(c)
--    -- buttons for the titlebar
--    local buttons = gears.table.join(
--        awful.button({ }, 1, function()
--            client.focus = c
--            c:raise()
--            awful.mouse.client.move(c)
--        end),
--        awful.button({ }, 3, function()
--            client.focus = c
--            c:raise()
--            awful.mouse.client.resize(c)
--        end)
--    )
--
--    awful.titlebar(c) : setup {
--        { -- Left
--            awful.titlebar.widget.iconwidget(c),
--            buttons = buttons,
--            layout  = wibox.layout.fixed.horizontal
--        },
--        { -- Middle
--            { -- Title
--                align  = "center",
--                widget = awful.titlebar.widget.titlewidget(c)
--            },
--            buttons = buttons,
--            layout  = wibox.layout.flex.horizontal
--        },
--        { -- Right
--            awful.titlebar.widget.floatingbutton (c),
--            awful.titlebar.widget.maximizedbutton(c),
--            awful.titlebar.widget.stickybutton   (c),
--            awful.titlebar.widget.ontopbutton    (c),
--            awful.titlebar.widget.closebutton    (c),
--            layout = wibox.layout.fixed.horizontal()
--        },
--        layout = wibox.layout.align.horizontal
--    }
--end)

-- Toggle titlebar on or off depending on s. Creates titlebar if it doesn't exist
local function setTitlebar(client, s)
    if s then
        if client.titlebar == nil then
            client:emit_signal("request::titlebars", "rules", {})
        end
        awful.titlebar.show(client)
    else
        awful.titlebar.hide(client)
    end
end


client.connect_signal("property::floating", function(c)
  setTitlebar(c, c.floating)
end)

client.connect_signal("manage", function(c)
  setTitlebar(c, c.floating or c.first_tag.layout == awful.layout.suit.floating)
end)

-- Show titlebars on tags with the floating layout
tag.connect_signal("property::layout", function(t)
    -- New to Lua ?
    -- pairs iterates on the table and return a key value pair
    -- I don't need the key here, so I put _ to ignore it
    for _, c in pairs(t:clients()) do
        if t.layout == awful.layout.suit.floating then
            setTitlebar(c, true)
        else
            setTitlebar(c, false)
        end
    end
end)

