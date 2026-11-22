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
    ./audio.nix
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix-mineral.settings.kernel.binfmt-misc = true;
  nix-mineral.kernel-modules.disable = {
    # CD/DVD support.
    cdrom-related = false;
    udf = false;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Override nix-mineral to power on Bluetooth at startup.
    settings.Policy.AutoEnable = true;
  };

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

  environment.systemPackages = with pkgs; [
    aseprite
    egl-wayland
    libva-utils
    libreoffice
    proton-meet-bin
    rapidraw
    (reaper.override { jackLibrary = pipewire.jack; })
  ];

  # Force intel-media-driver (iHD / i915) or nvidia
  environment.sessionVariables = {
    # VDPAU_DRIVER = "va_gl";
    NVD_BACKEND = "direct";
    LIBVA_DRIVER_NAME = "nvidia";

    # Firefox decodes video on the CPU, the NVIDIA workaround is unsafe
    # because it turns off the decoder sandbox
    #
    # Vulkan decoding keeps the sandbox but locks up Turing cards like this one
    # Lock up https://bugzilla.mozilla.org/show_bug.cgi?id=2058290
    # On by default https://bugzilla.mozilla.org/show_bug.cgi?id=2053144
    # media.hardware-video-decoding-vulkan.enabled = true

    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

}
