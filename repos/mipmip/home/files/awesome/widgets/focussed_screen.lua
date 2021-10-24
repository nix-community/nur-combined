local awful = require('awful')
local wibox = require('wibox')

-- Focused screen widget
local focused_screen_widget = wibox.widget{

    markup = "SCR: " .. tostring(awful.screen.focused().index),
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

function update_focused_screen_widget()
  local nr = "1️⃣"
  if(awful.screen.focused().index == 2) then
    nr = "2️⃣"
  end

  focused_screen_widget.text = "" .. nr

end

client.connect_signal("focus", update_focused_screen_widget)
client.connect_signal("unfocus", update_focused_screen_widget)

---- hook into awful.screen.focus()
original_screen_focus = awful.screen.focus

function awful.screen.focus(_screen)
    original_screen_focus(_screen)
    update_focused_screen_widget()
end

return focused_screen_widget
