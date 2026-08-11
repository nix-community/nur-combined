{config, ...}: {
  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    # Keep 32-bit graphics libraries available for Wine, Steam, and older games.
    enable32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Kernel parameters for NVIDIA/Wayland stability
  boot.kernelParams = [
    # Enable NVIDIA's DRM KMS (Direct Rendering Manager Kernel Mode Setting)
    # Required for proper Wayland support on NVIDIA
    "nvidia-drm.modeset=1"
    # Provide a framebuffer console through NVIDIA DRM during display handoff.
    "nvidia-drm.fbdev=1"
    # Keep GSP firmware disabled for the proprietary driver on this host.
    "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  # NVIDIA/Wayland stability environment variables for KDE Plasma 6
  environment.sessionVariables = {
    # Select NVIDIA as the GLX vendor through GLVND.
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Use the NVIDIA DRM backend for GBM clients.
    GBM_BACKEND = "nvidia-drm";
    # Select NVIDIA's VA-API driver.
    LIBVA_DRIVER_NAME = "nvidia";
    # Disable driver-side OpenGL synchronization to the display refresh.
    __GL_SYNC_TO_VBLANK = "0";
    # Required for Firefox/NVIDIA hardware acceleration
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # For now, we'll use the proprietary kernel modules for stability.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
