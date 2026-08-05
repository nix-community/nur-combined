{ pkgs, ... }:
{
  system.stateVersion = "25.05";
  nixpkgs.config.allowUnfree = true;
  security.sudo.wheelNeedsPassword = false;
  users.users.nixos = {
    password = "nixos";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  users.groups.nixos = { };

  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 2;
  };

  environment.systemPackages = [
    pkgs.tubearchivist
  ];

  services.tubearchivist = {
    enable = true;
    hostName = "localhost";

    settings = {
      username = "tubearchivist";
      password = "tubearchivist";
      port = 12321;
      mediaDir = "/var/lib/tubearchivist";
      debug = true;
      staticAuth = false;
    };
  };
}
