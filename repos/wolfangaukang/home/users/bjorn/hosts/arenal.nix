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
  inherit (localLib) generateHyprlandMonitorConfig generateKanshiOutput;
  hostDefaults = lib.importJSON "${self}/system/hosts/common/host_defaults.json";
  commands = import "${inputs.self}/home/users/bjorn/settings/wm-commands.nix" { inherit config lib pkgs; };

in
{
  imports = [
    "${self}/home/users/bjorn"
    "${self}/home/users/bjorn/profiles/workstation.nix"
  ];

  defaultajAgordoj.gui.terminal.font.size = 11;

  home.packages = with pkgs; [
    aegisub
    burpsuite
    stremio
  ];

  services.kanshi.settings = [
    {
      profile = {
        name = "docked";
        outputs = [
          (generateKanshiOutput hostDefaults hostname)
        ];
      };
    }
    {
      profile = {
        name = "connected";
        outputs = [
          (generateKanshiOutput hostDefaults hostname)
          ((generateKanshiOutput hostDefaults "irazu") // { position = "0,-1080"; })
        ];
      };
    }
  ];

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
          "XF86AudioLowerVolume" = "exec --no-startup-id ${commands.volume} -d 5";
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${commands.volume} -i 5";
          "XF86AudioMute" = "exec --no-startup-id ${commands.volumeMute}";
          #"XF86Sleep" = "exec ${commands.lock}";
        };
      };
      extraConfig = ''
        bindgesture swipe:left workspace next
        bindgesture swipe:right workspace prev
      '';
    };
    hyprland.settings = {
      monitor = generateHyprlandMonitorConfig hostDefaults hostname;
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
