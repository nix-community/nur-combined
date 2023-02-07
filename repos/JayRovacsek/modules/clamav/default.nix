{ pkgs, lib, ... }: {
  # Inspiration: https://github.com/houstdav000/dotfiles/blob/733f2db667e3645619ca9dc05446099864045a49/nixos/config/services/clamav.nix
  services.clamav = {
    updater = {
      enable = true;
      frequency = 24;
      interval = "hourly";
    };
    daemon = {
      enable = true;
      settings = {
        LogFile = "/var/log/clamd.log";
        LogTime = true;
        VirusEvent = lib.escapeShellArgs [
          "${pkgs.libnotify}/bin/notify-send"
          "--"
          "ClamAV Virus Scan"
          "Found virus: %v"
        ];
        DetectPUA = true;
      };
    };
  };
  environment.systemPackages = with pkgs; [ libnotify ];
}
