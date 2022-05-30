my_hotkey_help = {}

my_hotkey_help.readline = {
  keys = {
    ["readline"] = {
        {
            modifiers = { "Mod1" },
            keys = {
                b = "Backward one word",
                d = "Delete one word from cursor",
            }
        },
        {
            modifiers = { "Mod1", "Shift"},
            keys = {
                f = "Forward one word"
            }
        },
        {
            modifiers = { "CTRL", "Shift"},
            keys = {
                _ = "Undo last line edit"
            }
        },
        {
            modifiers = {"CTRL"},
            keys = {
                a = "Beginning of line",
                b = "Backward one character",
                d = "Delete one character",
                e = "End of line",
                f = "Forward one character",
                k = "Cut forwards to the end of the line",
                y = "Yank last cut",
                w = "Cut previous word"
            }
        }
    }
  }
}

my_hotkey_help.vifm = {
  keys = {
    ["vifm"] = {
      {
        modifiers = { },
        keys = {
          za = "toggle hidden files",
          dd = "delete file",
          M = "move to middle"
        }
      }
    }
  }
}

my_hotkey_help.feh = {
  group_color = "#009F00",
  group_title = "feh",
  rule = {
    class = { "feh", "feh" }
  },
  keys = {
    ["feh"] = {
      {
        modifiers = {  },
        keys = {
          ["Up"] = "Zoom in",
          ["Down"] = "Zoom out",
          ["/"] = "Zoom fit"
        }
      },
      {
        modifiers = { "Ctrl" },
        keys = {
          ["Delete"] = "Delete file"
        }
      }
    }
  }
}
my_hotkey_help.inkscape = {
  group_color = "#009F00",
  group_title = "Inkscape: tools",
  rule = {
    class = { "inkscape", "Inkscape" }
  },
  keys = {
    ["Inkscape: tools"] = {
      {
        modifiers = {  },
        keys = {
          s = "Selection tool"
        }
      },
      {
        modifiers = { "Ctrl" },
        keys = {
          n = "New window",
          o = "Open file"
        }
      }
    }
  }
}

return my_hotkey_help
