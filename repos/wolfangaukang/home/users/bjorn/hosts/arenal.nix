{
  inputs,
  pkgs,
  config,
  lib,
  localLib,
  osConfig,
  ...
}:

let
  inherit (inputs) self;
  displays = lib.importJSON "${self}/misc/displays.json";
  profiles = localLib.getNixFiles "${self}/home/users/bjorn/profiles/" [
    "sway"
    "workstation"
  ];
  commands = import "${self}/home/users/bjorn/settings/wm-commands.nix" { inherit config lib pkgs; };

in
{
  imports = profiles ++ [ "${self}/home/users/bjorn" ];

  home = {
    persistence."/mnt/persist/home/bjorn" = {
      allowOther = osConfig.programs.fuse.userAllowOther;
      directories = [ ".config/gPodder" ];
      files = [ ".wallpaper1.jpg" ];
    };
  };

  programs = {
    kitty.font.size = lib.mkForce 11;
    waybar.settings.mainBar = {
      output = [ displays.arenal.id ];
      modules-right = [
        "backlight"
        "battery"
      ];
      backlight."format" = "  {percent}%";
      battery = {
        "format" = "  {capacity}%";
        "states" = {
          "warning" = "20";
          "critical" = "7";
        };
      };
    };
  };

  services = {
    kanshi.settings =
      let
        kanshiDisplays = localLib.getKanshiDisplays;
      in
      [
        {
          profile = {
            name = "basico";
            outputs = [ kanshiDisplays.arenal ];
          };
        }
        {
          profile = {
            name = "sala";
            outputs = [
              (kanshiDisplays.arenal // { position = "0,${displays.sala.y}"; })
              (kanshiDisplays.sala // { position = "0,0"; })
            ];
          };
        }
        {
          profile = {
            name = "ofi";
            outputs = [
              (kanshiDisplays.arenal // { position = "${displays.ofi.x},0"; })
              (kanshiDisplays.ofi // { position = "0,0"; })
            ];
          };
        }
      ];
    swayidle.timeouts = [
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
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
            xkb_layout = "colemak-bs_cl,us";
            xkb_options = "compose:ralt,grp:ctrl_space_toggle";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };
        keybindings = builtins.listToAttrs (
          builtins.map
            (indicator: {
              name = "XF86MonBrightness${indicator}";
              value = "exec --no-startup-id ${commands.brightness} set 5%${
                if indicator == "Down" then "-" else "+"
              }";
            })
            [
              "Down"
              "Up"
            ]
        );
        output = {
          "${displays.arenal.id}".bg = "${config.home.homeDirectory}/.wallpaper.jpg fill";
          "${displays.ofi.id}".bg = "${config.home.homeDirectory}/.wallpaper1.jpg fill";
        };
      };
      extraConfig = ''
        bindgesture swipe:left workspace next
        bindgesture swipe:right workspace prev
      '';
    };
    hyprland.settings = {
      monitor =
        let
          arenal = displays.arenal;
        in
        "${arenal.id},preferred,auto,${arenal.scale}";
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
