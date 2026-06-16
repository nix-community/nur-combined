_: {
  # EasyEffects service
  home-manager.users.ac.services.easyeffects.enable = true;

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
