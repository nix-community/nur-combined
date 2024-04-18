{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.programs.plasma-desktop-lyrics = {
    enable = lib.mkEnableOption (lib.mdDoc "load post-quantum algorithm provider for OpenSSL 3.x") // {
      default = true;
    };
  };

  config = lib.mkIf config.programs.plasma-desktop-lyrics.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.qtwebsockets
      plasma-desktop-lyrics-plasmoid
    ];

    systemd.user.services.plasma-desktop-lyrics = {
      description = "Plasma Desktop Lyrics daemon";
      after = [ "network.target" ];
      before = [ "plasma-plasmashell.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.plasma-desktop-lyrics}/bin/PlasmaDesktopLyrics";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };
  };
}
