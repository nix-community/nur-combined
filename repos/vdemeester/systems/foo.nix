{ lib, ... }:

with lib;
let
  hostname = "foo";
  secretPath = ../secrets/machines.nix;
  secretCondition = (builtins.pathExists secretPath);
in
{
  imports = [
    ./modules
    (import ../users).vincent
    (import ../users).root
  ];

  nix.maxJobs = 2;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/884a3d57-f652-49b2-9c8b-f6eebd5edbeb";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C036-34B9";
    fsType = "vfat";
  };
  swapDevices = [{ device = "/dev/disk/by-uuid/e1833693-77ac-4d52-bcc7-54d082788639"; }];

  networking = {
    hostName = hostname;
  };

  profiles = {
    home = true;
    avahi.enable = true;
    git.enable = true;
    ssh.enable = true;
    dev.enable = true;
    yubikey.enable = true;
  };

  services.xserver.enable = true;
  services.xserver.layout = "fr(bepo),fr";
  services.xserver.xkbVariant = "oss";
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome3.enable = true;

  services.gnome3 = {
    core-os-services.enable = true;
    core-shell.enable = true;
    core-utilities.enable = true;
  };

  virtualisation.containers = {
    enable = true;
    registries = {
      search = [ "registry.fedoraproject.org" "registry.access.redhat.com" "registry.centos.org" "docker.io" "quay.io" ];
    };
    policy = {
      default = [{ type = "insecureAcceptAnything"; }];
      transports = {
        docker-daemon = {
          "" = [{ type = "insecureAcceptAnything"; }];
        };
      };
    };
  };
}
