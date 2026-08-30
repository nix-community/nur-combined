{...}: {
  imports = [
    ./hardware-configuration.nix
    # Core
    ../../modules/core/bluetooth.nix
    ../../modules/core/boot.nix
    ../../modules/core/cachyos.nix
    ../../modules/core/dpi.nix
    ../../modules/core/flatpak.nix
    ../../modules/core/fonts.nix
    ../../modules/core/locale.nix
    ../../modules/core/network.nix
    ../../modules/core/nvidia.nix
    ../../modules/core/nix.nix
    ../../modules/core/plasma.nix
    ../../modules/core/printing.nix
    ../../modules/core/sound.nix
    ../../modules/core/swap.nix
    ../../modules/core/system.nix
    ../../modules/core/users.nix
    # Apps
    # Development
    ../../modules/apps/development/default.nix
    ../../modules/apps/development/git-signing.nix
    ../../modules/apps/development/vscode.nix
    ../../modules/apps/development/zed.nix
    ## Languages
    ../../modules/apps/development/c-cpp.nix
    ../../modules/apps/development/dotnet.nix
    ../../modules/apps/development/go.nix
    ../../modules/apps/development/java.nix
    ../../modules/apps/development/javascript.nix
    ../../modules/apps/development/python.nix
    ../../modules/apps/development/rust.nix
    ## Frameworks
    ../../modules/apps/development/flutter.nix
    ## Game Development
    ../../modules/apps/development/godot.nix
    # Games
    ../../modules/apps/games.nix
    # AI/ML
    ../../modules/apps/ai/default.nix
    ../../modules/apps/ai/ollama.nix
    ../../modules/apps/ai/whisper.nix
    # Document Conversion
    ../../modules/apps/document-conversion.nix
    # Graphics
    ../../modules/apps/graphics.nix
    # Internet
    ../../modules/apps/internet.nix
    # Multimedia
    ../../modules/apps/multimedia.nix
    # Productivity
    ../../modules/apps/productivity.nix
    # Utilities
    ../../modules/apps/utilities/default.nix
    ../../modules/apps/utilities/konsave.nix
    ../../modules/apps/utilities/nixos-scripts.nix
    ../../modules/apps/utilities/wine.nix
    ../../modules/apps/utilities/zsh.nix
    # Virtualization
    ../../modules/apps/utilities/containers.nix
    ../../modules/apps/utilities/qemu.nix
    # Work
    ../../modules/apps/work/insurup.nix
  ];

  networking.hostName = "karakiz";

  # Allow unfree packages (NVIDIA drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # CUDA is scoped, NOT global. Setting nixpkgs.config.cudaSupport = true
  # here would pull unrelated packages (firefox, thunderbird, opencv, ...)
  # into CUDA rebuilds that miss cache.nixos.org and compile from source.
  # Instead, only the packages that actually need the GPU opt in:
  #   - ollama:      via pkgs.ollama-cuda        (modules/apps/ai/ollama.nix)
  #   - whisper-gui-cuda: via pkgs.pkgsCuda.python3 (pkgs/default.nix)
  # Do NOT set cudaCapabilities anywhere: pinning to ["8.9"] changes the
  # derivation hash so nothing matches the community cache and everything
  # (magma, torch, ...) compiles from source. Default capabilities resolve
  # to the prebuilt binaries the nix-community CUDA Hydra caches.

  # cache.nixos.org never builds/caches CUDA derivations (unfree license),
  # so these community caches carry prebuilt CUDA packages from the Nixpkgs
  # CUDA team's Hydra jobset.
  nix.settings.extra-substituters = [
    "https://cache.nixos-cuda.org"
    "https://cuda-maintainers.cachix.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.extra-trusted-public-keys = [
    "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # CachyOS kernel (custom module) + upstream system optimizations.
  cachyos = {
    enable = true;
    kernel.variant = "latest";
    kernel.lto = true;
    # Ryzen 7 7800X3D uses AMD Zen 4.
    kernel.march = "zen4";
  };
  # cachyos.settings.enable activates system-level tuning (zram, I/O schedulers, audio, systemd)
  # via cachyos-settings-nix, independent of the kernel module above.
  cachyos.settings.enable = true;

  boot.loader.systemd-boot = {
    extraEntries."windows11-atlas.conf" = ''
      title Windows 11 Atlas OS
      efi /EFI/Microsoft/Boot/bootmgfw.efi
      sort-key o_windows_11_atlas
    '';
    # Keep the manual Windows entry ordered after the NixOS-managed boot entries.
    # auto-entries no suppresses automatic detection of other EFI partitions.
    extraInstallCommands = ''
      printf '\nauto-entries no\n' >> /boot/loader/loader.conf
    '';
  };
}
