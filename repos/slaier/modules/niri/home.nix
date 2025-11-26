{ pkgs, ... }:
let
  bg = "backgrounds/nixos/nix-wallpaper-dracula.png";
  bgPath = "${pkgs.nixos-artwork.wallpapers.dracula}/share/${bg}";
in
{
  home.packages = [ pkgs.swaybg ];
  xdg.dataFile."${bg}".source = bgPath;
  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
  services.swayidle =
    let
      # Lock command
      lock = "${pkgs.swaylock}/bin/swaylock --daemonize -i ${bgPath}";
      # Niri
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
    in
    {
      enable = true;
      systemdTarget = "niri.service";
      timeouts = [
        {
          timeout = 300; # in seconds
          command = "${pkgs.libnotify}/bin/notify-send 'Locking in 30 seconds' -t 30000";
        }
        {
          timeout = 330;
          command = lock;
        }
        {
          timeout = 360;
          command = display "off";
          resumeCommand = display "on";
        }
      ];
      events = [
        {
          event = "before-sleep";
          # adding duplicated entries for the same event may not work
          command = (display "off") + "; " + lock;
        }
        {
          event = "after-resume";
          command = display "on";
        }
        {
          event = "lock";
          command = (display "off") + "; " + lock;
        }
        {
          event = "unlock";
          command = display "on";
        }
      ];
    };
}
