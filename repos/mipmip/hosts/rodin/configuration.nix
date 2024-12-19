{ config, inputs, system, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../_roles/desktop.nix
    ../_roles/dev-machine.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  nix = {
    package = pkgs.nixVersions.stable;
    settings.trusted-substituters = [
      "http://attic.np-tools.technative.cloud:8080/jeroen"
    ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # TODO NEEDED?
  virtualisation.libvirtd.enable = true;

  services.flatpak.enable = true;
  services.tailscale.enable = true;
  services.guacamole-server.enable = true;
  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-port = 4822;
      guacd-hostname = "localhost";
    };
  };


  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "rodin";
  networking.networkmanager.enable = true;
  networking.firewall.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "22.11";

  #PACKAGES WHICH NEED A CUDA CARD
  environment.systemPackages = with pkgs; [
    upscayl
  ];

  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true;
    kernel = "https://boot.netboot.xyz";
  };

  #services.onedrive.enable = true;

  networking.hosts = {
    "127.0.0.1" = [
      "ojs"
      "localhost"
    ];
    "3.122.241.107" = [
      "rrs-dev.healtcheck.internal"
      "rrs-acc.healtcheck.internal"
      "rrs-test.healtcheck.internal"
    ];
  };

}

