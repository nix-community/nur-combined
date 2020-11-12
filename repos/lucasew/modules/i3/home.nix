{pkgs, config, ... }:
let
  mod = "Mod4";
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
in
{
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      terminal = "${pkgs.xfce.xfce4-terminal}/bin/xfce4-terminal";
      menu = "my-rofi";
      modifier = mod;
    };
    extraConfig = ''
exec --no-startup-id ${pkgs.networkmanagerapplet}/bin/nm-applet
bindsym XF86AudioRaiseVolume exec ${pactl} set-sink-volume @DEFAULT_SINK@ +10%
bindsym XF86AudioLowerVolume exec ${pactl} set-sink-volume @DEFAULT_SINK@ -10%
bindsym XF86AudioMute exec ${pactl} set-sink-volume @DEFAULT_SINK@ toggle
bindsym XF86AudioMicMute exec ${pactl} set-sink-volume @DEFAULT_SOURCE@ toggle
bindsym ${mod}+l exec ${pkgs.xautolock}/bin/xautolock -locknow

bindsym XF86AudioNext exec ${playerctl} next
bindsym XF86AudioPrev exec ${playerctl} previous
bindsym XF86AudioPlay exec ${playerctl} play-pause
bindsym XF86AudioPause exec ${playerctl} play-pause

exec --no-startup-id ${pkgs.feh}/bin/feh --bg-center ~/.background-image

new_window 1pixel
    '';
  };
}
