{
  self,
  global,
  pkgs,
  config,
  lib,
  ...
}@args:
let
  inherit (self) inputs;
  inherit (global) username;
  hostname = "whiterun";
in
{
  imports = [
    ./hardware-configuration.nix
    ../gui-common

    "${self.inputs.nixos-hardware}/common/cpu/amd/pstate.nix"
    "${self.inputs.nixos-hardware}/common/gpu/amd"
    "${self.inputs.nixos-hardware}/common/pc/ssd"
    ./nvidia.nix

    ./dlna.nix
    ./zfs.nix
    # ./container-inet-rdp.nix
    ./container-nat.nix
    ./plymouth.nix
  ];


  programs.nix-ld.enable = true;

  hardware.nvidia.modesetting.enable = false;

  gc-hold.enable = true;

  boot.kernel.sysctl = {
    "vfs.zfs.arc_sys_free" = 4 * 1024 * 1024 * 1024; # make ZFS free arc before hitting swap
  };

  networking.interfaces.enp5s0.wakeOnLan.enable = true;

  fileSystems."/media/downloads" = {
    device = "/dev/disk/by-label/downloads";
    options = [
      "commit=60"
      "noatime"
    ];
    fsType = "ext4";
  };

  fileSystems."/media/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "ext4";
  };

  fileSystems."/media/ssd240" = {
    device = "/dev/disk/by-label/ssd240";
    fsType = "btrfs";
  };

  fileSystems."/media/ssd1tb" = {
    device = "/dev/disk/by-label/ssd1tb";
    fsType = "ext4";
  };

  nix.settings.min-free = 50 * 1024 * 1024 * 1024; # 50GB

  programs.ccache.enable = true;

  services.sunshine.enable = true;

  # services.xserver.windowManager.i3.enable = true;
  # programs.hyprland.enable = true;
  programs.sway.enable = true;

  services.hardware.openrgb.enable = true;

  programs.gamemode.enable = true;

  # services.boinc.enable = true;

  services.flatpak.enable = true;

  networking.hostId = "97e3b5a7";

  virtualisation.containerd.enable = true;

  services.telegram-sendmail.enable = true;

  services.cloud-savegame = {
    enable = true;
    calendar = "00:00:01";
    settings = {
      search = {
        paths = [
          "/media/downloads/steam/steamapps/compatdata"
          "/media/ssd240/steam/steamapps/compatdata"
        ];
      };
      flatout-2 = {
        installdir = [ "/media/downloads/steam/steamapps/common/FlatOut2" ];
      };
    };
  };

  services.cockpit.enable = true;

  services.nomad.enable = true;

  # services.magnetico.enable = true;

  boot = {
    supportedFilesystems = [
      "ntfs"
      "xfs"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        # useOSProber = true; # TODO: test that VM scheme with SATA passthrough first
      };
    };
  };
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.rocm-runtime
    rocmPackages.clr
  ];
  hardware.graphics.extraPackages32 = with pkgs; [ ];

  programs.steam.enable = true;

  networking.hostName = hostname;

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  services.openssh.settings.X11Forwarding = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
