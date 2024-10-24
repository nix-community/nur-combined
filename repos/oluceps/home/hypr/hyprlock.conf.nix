{ pkgs, ... }:
''
  background {
      monitor =
      #path = screenshot
      path = ${
        pkgs.fetchurl {
          url = "https://s3.nyaw.xyz/misskey//92772482-aef9-44e8-b1e2-1d49753a72fc.jpg";
          hash = "sha256-Y9TJ/xQQhqWq3t2wn1gS4NPGpuz1m7nu1ATcWWPKPW8=";
        }
      }
      #color = $background
      blur_passes = 2
      contrast = 1
      brightness = 0.5
      vibrancy = 0.2
      vibrancy_darkness = 0.2
  }

  general {
      no_fade_in = true
      no_fade_out = true
      hide_cursor = true
      grace = 0
      disable_loading_bar = true
  }

  input-field {
      monitor =
      size = 250, 60
      outline_thickness = 2
      dots_size = 0.2 # Scale of input-field height, 0.2 - 0.8
      dots_spacing = 0.35 # Scale of dots' absolute size, 0.0 - 1.0
      dots_center = true
      outer_color = rgba(0, 0, 0, 0)
      inner_color = rgba(0, 0, 0, 0.2)
      font_color = rgba(255, 255, 255, 0.3)
      fade_on_empty = false
      rounding = -1
      check_color = rgb(204, 136, 34)
      placeholder_text = <i><span foreground="##cdd6f4">Password</span></i>
      hide_input = false
      position = 0, -200
      halign = center
      valign = center
  }

  # DATE
  label {
    monitor =
    text = cmd[update:1000] get-date
    color = rgba(242, 243, 244, 0.75)
    font_size = 22
    font_family = JetBrains Mono
    position = 0, 300
    halign = center
    valign = center
  }

  # TIME
  label {
    monitor = 
    text = cmd[update:1000] get-time
    color = rgba(242, 243, 244, 0.75)
    font_size = 95
    font_family = Intel One Mono Medium
    position = 0, 200
    halign = center
    valign = center
  }


  # Profile Picture
  image {
      monitor =
      path = ${
        pkgs.fetchurl {
          url = "https://s3.nyaw.xyz/misskey//a9edc77f-c775-475c-924f-9f13dd97e343.png";
          hash = "sha256-mVpr5sOD2HUBQ1mIt8RZ1gSe1QBRmYBbxEOP7lfjMQ4=";
        }
      }
      size = 100
      border_size = 2
      position = 0, -50
      halign = center
      valign = center
  }
''
