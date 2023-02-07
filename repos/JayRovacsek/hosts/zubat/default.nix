{ config, pkgs, lib, flake, ... }:
let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) cli;
  inherit (flake.lib) merge-user-config;

  jay = common.users.jay {
    inherit config pkgs;
    modules = cli;
  };

  merged = merge-user-config { users = [ jay ]; };

  hostName = "zubat";
in {
  inherit flake;
  inherit (merged) users home-manager;

  age.identityPaths = [ "/agenix/id-ed25519-ssh-primary" ];

  imports = [ ./modules.nix ./system-packages.nix ];

  networking = { inherit hostName; };

  wsl = {
    defaultUser = "jay";
    enable = true;
    startMenuLaunchers = true;
    wslConf.automount.root = "/mnt";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.05";
}
