{self, global, pkgs, config, lib, ...}:
let
  inherit (self) inputs;
  inherit (global) username;
  hostname = "whiterun";
in {
  imports = [
    ../gui-common
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    ./sshfs.nix
  ];
  boot = {
    supportedFilesystems = [ "ntfs" ];
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";
        # useOSProber = true; # TODO: test that VM scheme with SATA passthrough first
      };
    };
  };
  networking.hostName = hostname;

  boot.kernelPackages = pkgs.linuxPackages_5_15;

  services.openssh.forwardX11 = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
