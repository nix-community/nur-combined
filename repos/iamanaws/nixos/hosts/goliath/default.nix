{
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

  programs.zoom-us.enable = true;

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
