{ inputs
, pkgs
, config
, lib
, ...
}:

let
  inherit (inputs) self;
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

  wayland.windowManager.hyprland.settings = {
    gestures = {
      workspace_swipe = true;
      workspace_swipe_fingers = 3;
      workspace_swipe_forever = false;
      workspace_swipe_numbered = true;
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
