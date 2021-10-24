local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local naughty = require("naughty")
local debug = require("debug")
local module = {}

local generate_filter = function(i)
  return function(c, scr)
    local t = scr.tags[i]
    local ctags = c:tags()
    for _, v in ipairs(ctags) do
      if v == t then
        return true
      end
    end
    return false
  end
end

local fancytasklist = function(cfg, tag_index)
  return awful.widget.tasklist{
    screen = cfg.screen or awful.screen.focused(),
    filter = generate_filter(tag_index),
    buttons = cfg.tasklist_buttons,
    widget_template = {
      {
        id = "clienticon",
        widget = awful.widget.clienticon
      },
      layout = wibox.layout.stack,
      create_callback = function(self, c, _, _)
        self:get_children_by_id("clienticon")[1].client = c
        awful.tooltip{
          objects = { self },
          timer_function = function()
            return c.name
          end
        }
      end
    }
  }
end

function module.new(config)

  local cfg = config or {}

  local s = cfg.screen or awful.screen.focused()
  local taglist_buttons = cfg.taglist_buttons

  return awful.widget.taglist{
    screen = s,
    filter = awful.widget.taglist.filter.all,
    bg = "ffffff00";
    widget_template = {

      {
        {
          {
            {

              {
                {
                  {
                    id="text_button",
                    text = "I'm a button!",
                    align = "center",
                    widget = wibox.widget.textbox
                  },
                  --top = 1, bottom = 1, left = 1, right = 1,
                  margins = 0,
                  widget = wibox.container.margin
                },
                id = "text_button_border",
                bg = '#cccccc11', -- basic
                --bg = '#00000000', --tranparent
                shape_border_width = 1,
                shape_border_color = '#4C566A', -- outline
                shape = function(cr, width, height)
                  gears.shape.rounded_rect(cr, width, height, 1)
                end,
                widget = wibox.container.background
              },
              {
                id = "tasklist_placeholder",
                layout = wibox.layout.fixed.horizontal,
              },
              layout = wibox.layout.ratio.vertical,
              align = "center"
            },
            id = "background_role",
            widget = wibox.container.background
          },
          shape_border_width = 0,
          id="border_role",
          shape_border_color = '#4C566A',
          shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 1)
          end,
          widget = wibox.container.background
        },

        margins = dpi(2),
        widget = wibox.container.margin
      },

      layout = wibox.layout.fixed.horizontal,
      create_callback = function(self, _, index, _)
        self:get_children_by_id("tasklist_placeholder")[1]:add(fancytasklist(cfg, index))
        self:get_children_by_id("text_button")[1].markup = '<small> '..index..' </small>'

        awful.screen.focus(1)
        local screen = awful.screen.focused()
        local tag = screen.tags[index]
        local current_layout = awful.tag.getproperty(tag, 'layout')
        if (current_layout == awful.layout.suit.floating) then
          self:get_children_by_id("text_button_border")[1].shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 4)
          end
        end

        self:get_children_by_id("background_role")[1]:connect_signal(
        'button::press',
        function()

          awful.screen.focus(1)
          local screen = awful.screen.focused()
          local tag = screen.tags[index]
          if tag then
            tag:view_only()
          end

        end
        )

      end
    },
    buttons = taglist_buttons
  }
end

return module
