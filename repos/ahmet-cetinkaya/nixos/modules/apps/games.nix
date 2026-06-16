{pkgs, ...}: {
  # Flatpak
  services.flatpak.packages = [
    # Platforms
    "com.valvesoftware.Steam"
    "net.lutris.Lutris"
  ];
}
