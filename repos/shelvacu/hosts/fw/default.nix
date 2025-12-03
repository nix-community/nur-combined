{
  inputs,
  pkgs,
  vacuModules,
  vacuRoot,
  ...
}:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    /${vacuRoot}/tf2
    vacuModules.sops
    ./apex.nix
    ./android.nix
    ./thunderbolt.nix
    ./fwupd.nix
    ./zfs.nix
    ./virtualbox.nix
    ./tpm-fido.nix
    ./podman.nix
    ./waydroid.nix
    ./audio.nix
    ./boot.nix
  ];

  vacu.hostName = "fw";
  vacu.shell.color = "magenta";
  vacu.verifySystem.expectedMac = "e8:65:38:52:5c:59";
  vacu.systemKind = "laptop";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # standard kernel: waydroid works, always zfs-compatible
  # lqx kernel: games run with less stutters
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_lqx;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;

  networking.networkmanager.enable = true;
  services.irqbalance.enable = true;
  # boot.kernelParams = [ "nvme.noacpi=1" ]; # DONT DO IT: breaks shit even more

  services.fprintd.enable = false; # kinda broken

  users.users.shelvacu.extraGroups = [ "dialout" ];

  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  vacu.packages = ''
    android-studio
    framework-tool
    fw-ectool
    headsetcontrol
    openterface-qt
    intiface-central
    osu-lazer
    mumble
    mullvad-vpn
    obs-studio
    # jellyfin-media-player # depends on marked-insecure qtwebengine :weary:
    kdePackages.ktorrent
  '';

  services.power-profiles-daemon.enable = true;

  networking.firewall.enable = false;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.printing.enable = true;
  programs.system-config-printer.enable = true;

  networking.hostId = "c6e309d5";

  services.openssh.enable = true;
  system.stateVersion = "23.11"; # Did you read the comment?
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  #boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  #boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "fw/root";
    fsType = "zfs";
  };

  fileSystems."/cache" = {
    device = "fw/cache";
    fsType = "zfs";
  };

  fileSystems."/home/shelvacu/cache" = {
    device = "/cache/shelvacu";
    options = [ "bind" ];
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableAllFirmware = true;
  hardware.graphics.extraPackages = [
    pkgs.rocmPackages.clr.icd
  ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  hardware.openrazer = {
    enable = true;
    users = [ "shelvacu" ];
  };
  services.blueman.enable = true;
  programs.nix-ld.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.postgresql.enable = true; # for development

  vacu.programs.thunderbird.enable = true;

  services.mullvad-vpn.enable = true;
}
