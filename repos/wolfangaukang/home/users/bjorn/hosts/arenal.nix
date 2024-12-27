{ inputs
, pkgs
, config
, lib
, localLib
, hostname
, ...
}:

let
  inherit (inputs) self;
  inherit (localLib) generateHyprlandMonitorConfig generateKanshiOutput getHostDefaults;
  hostInfo = getHostDefaults hostname;
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" { inherit config lib pkgs; };

in
{
  imports = [
    "${self}/home/users/bjorn"
    "${self}/home/users/bjorn/profiles/workstation.nix"
    "${self}/home/users/bjorn/profiles/sway.nix"
  ];

  defaultajAgordoj.gui.terminal.font.size = 11;

  home.packages = with pkgs; [
    aegisub
    burpsuite
    stremio
  ];

  programs.waybar.settings.mainBar = {
    modules-right = [ "backlight" "battery" ];
    backlight."format" = "  {percent}%";
    battery = {
      "format" = "  {capacity}%";
      "states" = {
        "warning" = "20";
        "critical" = "7";
      };
    };
  };

  services = {
    kanshi.settings =
      let
        defaultOutput = [ (generateKanshiOutput hostInfo) ];
      in [
        {
          profile = {
            name = "basico";
            outputs = defaultOutput;
          };
        }
        {
          profile = {
            name = "sala";
            outputs = defaultOutput // [
              {
                criteria = "XXX AAA Unknown";
                mode = "1920x1080@60Hz";
              }
            ];
          };
        }
        {
          profile = {
            name = "ofi";
            outputs = defaultOutput // [
              {
                criteria = "ASUSTek COMPUTER INC ASUS VA27EHE L1LMTF068194";
                mode = "1920x1080@60Hz";
              }
            ];
          };
        }
      ];
    wlsunset = {
      enable = config.wayland.windowManager.sway.enable || config.wayland.windowManager.hyprland.enable;
      latitude = "12.13282";
      longitude = "-86.2504";
      temperature = {
        day = 6500;
        night = 2500;
      };
    };
  };

  wayland.windowManager = {
    sway = {
      config = {
        input = {
          "1:1:AT_Translated_Set_2_keyboard" = {
            xkb_variant = "colemak,";
            xkb_layout = "colemak-bs_cl";
            xkb_options = "compose:ralt";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };
        keybindings = {
          "XF86MonBrightnessDown" = "exec --no-startup-id ${commands.brightness} set 5%-";
          "XF86MonBrightnessUp" = "exec --no-startup-id ${commands.brightness} set 5%+";
          #"XF86Sleep" = "exec ${commands.lock}";
        };
      };
      extraConfig = ''
        bindgesture swipe:left workspace next
        bindgesture swipe:right workspace prev
      '';
    };
    hyprland.settings = {
      monitor = generateHyprlandMonitorConfig hostInfo;
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_forever = false;
        #workspace_swipe_numbered = true;
      };
      bindl = [
        ", switch:off:Lid Switch, exec, systemctl suspend"
      ];
      bind = [
        ", XF86MonBrightnessDown, exec, ${commands.brightness} set 5%-"
        ", XF86MonBrightnessUp, exec, ${commands.brightness} set 5%+"
        ", XF86AudioLowerVolume, exec, ${commands.volume} -d 5"
        ", XF86AudioRaiseVolume, exec, ${commands.volume} -i 5"
        ", XF86AudioMute, exec, ${commands.volumeMute}"
        ", XF86Sleep, exec, ${commands.lock}"
      ];
    };
  };
}
