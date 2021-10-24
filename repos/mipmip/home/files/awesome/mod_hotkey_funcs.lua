local mod_hotkey_funcs = {}

local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local function raise_client()
   if client.focus then
      client.focus:raise()
   end
end

local floating_resize_amount = dpi(20)
local floating_moving_amount = dpi(20)
local tiling_resize_factor = 0.05

-- ===================================================================
-- Functions (Called by some keybinds)
-- ===================================================================

-- Move given client to given direction
function mod_hotkey_funcs.move_client(c, direction)
   -- If client is floating, move to edge
   if c.floating or (awful.layout.get(mouse.screen) == awful.layout.suit.floating) then
      local workarea = awful.screen.focused().workarea


      --if direction == "up" then
         --c:geometry({nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil})
      --elseif direction == "down" then
         --c:geometry({nil, y = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil})
      --elseif direction == "left" then
         --c:geometry({x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil})
      --elseif direction == "right" then
         --c:geometry({x = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil, nil})
      --end

      if direction == "up" then
         c:relative_move(0, -floating_moving_amount, 0, 0)
      elseif direction == "down" then
         c:relative_move(0, floating_moving_amount, 0, 0)
      elseif direction == "left" then
         c:relative_move(-floating_moving_amount, 0, 0, 0)
      elseif direction == "right" then
         c:relative_move(floating_moving_amount, 0, 0, 0)
      end

   -- Otherwise swap the client in the tiled layout
   elseif awful.layout.get(mouse.screen) == awful.layout.suit.max then
      if direction == "up" or direction == "left" then
         awful.client.swap.byidx(-1, c)
      elseif direction == "down" or direction == "right" then
         awful.client.swap.byidx(1, c)
      end
   else
      awful.client.swap.bydirection(direction, c, nil)
   end
end


function mod_hotkey_funcs.resize_client(c, direction)
   if awful.layout.get(mouse.screen) == awful.layout.suit.floating or (c and c.floating) then
      if direction == "up" then
         c:relative_move(0, 0, 0, -floating_resize_amount)
      elseif direction == "down" then
         c:relative_move(0, 0, 0, floating_resize_amount)
      elseif direction == "left" then
         c:relative_move(0, 0, -floating_resize_amount, 0)
      elseif direction == "right" then
         c:relative_move(0, 0, floating_resize_amount, 0)
      end
   else
      if direction == "up" then
         awful.client.incwfact(-tiling_resize_factor)
      elseif direction == "down" then
         awful.client.incwfact(tiling_resize_factor)
      elseif direction == "left" then
         awful.tag.incmwfact(-tiling_resize_factor)
      elseif direction == "right" then
         awful.tag.incmwfact(tiling_resize_factor)
      end
   end
end


function mod_hotkey_funcs.focus_bydirection_down()
  awful.client.focus.global_bydirection("down")
  raise_client()
end
function mod_hotkey_funcs.focus_bydirection_up()
  awful.client.focus.global_bydirection("up")
  raise_client()
end
function mod_hotkey_funcs.focus_bydirection_left()
  awful.client.focus.global_bydirection("left")
  raise_client()
end
function mod_hotkey_funcs.focus_bydirection_right()
  awful.client.focus.global_bydirection("right")
  raise_client()
end

function mod_hotkey_funcs.audio_volume_up()
  awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%", false)
  awesome.emit_signal("volume_change")
end
function mod_hotkey_funcs.audio_volume_down()
  awful.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ -5%", false)
  awesome.emit_signal("volume_change")
end

function mod_hotkey_funcs.toggle_desktop()
  if desktop_apps_minimized then
    for _, cl in ipairs(mouse.screen.selected_tag:clients()) do
      local c = cl
      if c then
        c.minimize = false
      end
      c:emit_signal(
      "request::activate", "key.unminimize", {raise = true}
      )
    end
    desktop_apps_minimized = false
  else
    for _, cl in ipairs(mouse.screen.selected_tag:clients()) do
      local c = cl
      if c then
        if (not (c.class == "Nemo-desktop") ) then
          c.minimized = true
        end
      end
    end
    desktop_apps_minimized = true
  end
end

return mod_hotkey_funcs
