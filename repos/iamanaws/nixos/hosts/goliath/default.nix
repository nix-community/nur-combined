{
  lib,
  pkgs,
  nixosModules,
  ...
}:

{
  imports = with nixosModules; [
    gaming
    hardened
    services.flatpak
  ];

  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linuxKernel.kernels.linux_6_12;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix-mineral.settings.kernel.binfmt-misc = true;

  services.xserver.xkb.layout = "latam";

  services.flatpak.packages = [
    "net.sourceforge.VMPK"
    "com.github.tchx84.Flatseal"
    # "io.github.nokse22.asciidraw"
    # "app.drey.EarTag"
    # "xyz.slothlife.Jogger"
    # "com.jeffser.Alpaca"
    # mission center
    # garden.jamie.Morphosis
  ];

  programs.solaar.enable = true;
  programs.zoom-us.enable = true;

  # Keep GNOME as the default, but select Hyprland for iamanaws.
  systemd.services.display-manager.preStart = lib.mkAfter ''
    busctl=${pkgs.systemd}/bin/busctl
    read -r _ account_path < <(
      "$busctl" call \
        org.freedesktop.Accounts /org/freedesktop/Accounts \
        org.freedesktop.Accounts FindUserByName s iamanaws
    )
    account_path="''${account_path//\"/}"

    for setting in SetSession:hyprland SetSessionType:wayland; do
      "$busctl" call org.freedesktop.Accounts "$account_path" \
        org.freedesktop.Accounts.User "''${setting%%:*}" s "''${setting#*:}"
    done
  '';

  environment.systemPackages = with pkgs; [
    aseprite
    egl-wayland
    libva-utils
    libreoffice
    rapidraw
    reaper
  ];

  # Force intel-media-driver (iHD / i915) or nvidia
  environment.sessionVariables = {
    # VDPAU_DRIVER = "va_gl";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";
    MOZ_DISABLE_RDD_SANDBOX = "1";

    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

}
