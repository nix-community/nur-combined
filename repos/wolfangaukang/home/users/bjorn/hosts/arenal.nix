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

  services.kanshi.profiles = {
    undocked.outputs = [
      (generateKanshiOutput hostDefaults hostname)
    ];
    connected.outputs = [
      (generateKanshiOutput hostDefaults hostname)
      ((generateKanshiOutput hostDefaults "irazu") // { position = "0,-1080"; })
    ];
  };

  wayland.windowManager.hyprland.settings = {
    monitor = generateHyprlandMonitorConfig hostDefaults hostname;
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
      workspace_swipe_forever = false;
      #workspace_swipe_numbered = true;
    };
    bindl = [
      ", switch:on:Lid Switch, exec, ${commands.lock}"
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
}
