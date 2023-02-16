{ pkgs, ... }:

{
  home.packages = with pkgs; [
    playerctl
    sway-contrib.grimshot
    swaylock
    xorg.xset
  ];

  wayland.windowManager.sway.config = {
    input = {
      "2:7:SynPS/2_Synaptics_TouchPad" = {
        dwt = "enabled";
        tap = "enabled";
        natural_scroll = "enabled";
      };
    };
    keybindings = let
      modifier = config.wayland.windowManager.sway.config.modifier;
      swaylock = "swaylock -i /home/bjorn/.wallpaper -s fill -s fill -efkl";
      default_sink = "0";
      mic_source = "1";
    in lib.mkOptionDefault {
      #XF86WLAN, XF86Sleep are already configured
      "XF86AudioLowerVolume" = "exec --no-startup-id sh -c \"amixer set Master 5%-\"";
      "XF86AudioRaiseVolume" = "exec --no-startup-id sh -c \"amixer set Master 5%+\"";
      "XF86AudioMute" = "exec --no-startup-id sh -c \"pactl set-sink-mute ${default_sink} toggle\"";
      "XF86AudioMicMute" = "exec --no-startup-id sh -c \"pactl set-source-mute ${mic_source} toggle\"";
      "XF86AudioPlay" = "exec --no-startup-id sh -c \"playerctl play-pause\"";
      "XF86AudioPrev" = "exec --no-startup-id sh -c \"playerctl previous\"";
      "XF86AudioNext" = "exec --no-startup-id sh -c \"playerctl next\"";
      "XF86Sleep" = "exec ${swaylock}";
      "XF86ScreenSaver" = "exec ${swaylock}";
    };
  };
}