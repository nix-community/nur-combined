{
  inputs,
  outputs,
  lib,
  pkgs,
  nixosModules,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
  ]
  ++ (with nixosModules.programs; [
    nix
    gnupg
  ]);

  boot = {
    initrd.systemd.enable = lib.mkDefault true;

    loader = {
      efi.canTouchEfiVariables = lib.mkDefault true;

      systemd-boot = {
        enable = lib.mkDefault true;
        # configurationLimit = 50;
        editor = false;
      };
    };
  };

  networking.networkmanager.enable = lib.mkDefault true;

  console = {
    #font = "Lat2-Terminus16";
    packages = lib.mkDefault [ pkgs.terminus_font ];
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-i18b.psf.gz";
    keyMap = lib.mkDefault "la-latin1";
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  services.fwupd.enable = lib.mkDefault true;
  virtualisation.vmVariant.services.fwupd.enable = false;

  # List packages installed in system profile.
  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [
    # bat
    bottom
    busybox
    fet-sh
    file
    git
    lshw
    # ripgrep
    sops
    tldr
  ];
}
