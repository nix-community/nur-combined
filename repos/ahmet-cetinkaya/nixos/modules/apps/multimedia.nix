{pkgs, ...}: {
  # EasyEffects service
  home-manager.users.ac.services.easyeffects.enable = true;

  # Ensure EasyEffects starts after PipeWire is ready
  home-manager.users.ac.systemd.user.services.easyeffects = {
    Unit = {
      After = ["pipewire.service" "wireplumber.service" "graphical-session.target"];
      Requires = ["pipewire.service"];
    };
    Service = {
      RestartSec = 5;
    };
  };

  # Flatpak
  services.flatpak.packages = [
    # Video Players
    "io.mpv.Mpv"
    # Streaming
    "com.stremio.Stremio"
    "org.qbittorrent.qBittorrent"
    # Cloud Storage
    "com.nextcloud.desktopclient.nextcloud"
  ];
}
