{ pkgs, ... }:
{
  systemd.services.dlna = {
    description = "Hora do cinema garai";
    path = with pkgs; [ rclone ];
    script = ''
      rclone serve dlna --name filmez /media/downloads/TORRENTS --verbose
    '';
  };
}
