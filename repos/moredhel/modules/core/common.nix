# Common configuration between machines

{ config, pkgs, options, ... }:
let
  secrets = import /etc/nixos/secrets.nix;
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/share"];

  # TODO: put this in a more easily configurable location
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nix = {
    binaryCaches = [
      "https://moredhel.cachix.org"
      "https://cache.nixos.org"
    ];
    binaryCachePublicKeys = [
      "moredhel.cachix.org-1:ybc5aQq6Yxo4790aFGOpdfHd4Uxd0eqPVnnwK4ynQbo="
    ];
    trustedUsers = [ "root" "moredhel" ];
    useSandbox = true;
    nixPath = 
      options.nix.nixPath.default ++
      ["nixpkgs-overlays=/etc/nixos/overlays"];
        # "nixpkgs-overlays=/etc/nixos/overlays:/data/src/nix/cs-nixpkgs-overlay/default.nix"
  };

  boot.cleanTmpDir = true;

  # have my console configure to dvorak by default
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = null;

  networking.firewall.enable = true;


  services = {
    keybase.enable = true;
    kbfs = {
      enable = true;
    };

    syncthing = {
      enable = true;
      user = "moredhel";
      # dataDir = "/etc/nixos/private/syncthing";
      openDefaultPorts = true;
    };
  };

  programs.bash = {
    enableCompletion = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraTmuxConf = ''
    set -g mouse on;
    '';
  };

  users.mutableUsers = false;
  users.extraUsers.moredhel = {
    isNormalUser = true;
    extraGroups = [
    "wheel"
    "systemd-journal"
    "users"
    "docker"
    # "rkt"
    # "vboxusers" # fairly obvious
    # "dialout" # arduino stuff
    ];
    password = secrets.moredhel.password;
    uid = 1000;
  };

  virtualisation = {
    docker.enable = true;
    docker.enableOnBoot = false;
    docker.package = pkgs.docker-edge;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";

}
