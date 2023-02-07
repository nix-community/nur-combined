{ config, pkgs, lib, flake, ... }:

let
  inherit (flake) common;
  inherit (flake.common.home-manager-module-sets) cli;
  inherit (flake.lib) merge-user-config;

  builder = common.users.builder {
    inherit config pkgs;
    modules = [ ];
  };

  jay = common.users.jay {
    inherit config pkgs;
    modules = cli;
  };

  merged = merge-user-config { users = [ builder jay ]; };

in {
  inherit flake;
  inherit (merged) users home-manager;

  age.identityPaths =
    [ "/agenix/id-ed25519-ssh-primary" "/agenix/id-ed25519-headscale-primary" ];

  virtualisation.oci-containers.backend = "docker";

  services.tailscale.tailnet = "admin";

  security.sudo.wheelNeedsPassword = false;

  ## Todo: write out the below - need to rework networking module.
  networking = {
    wireless.enable = false;
    hostId = "acd009f4";
    hostName = "dragonite";
    useDHCP = false;
    interfaces.enp9s0.useDHCP = true;

    firewall = {
      ## Todo: remove below as they can be abstracted into microvms
      # For reference:
      # 5900: VNC (need to kill)
      # 8200: Duplicati
      allowedTCPPorts = [ 5900 8200 ];
    };
  };

  imports =
    [ ./hardware-configuration.nix ./modules.nix ./system-packages.nix ];

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  system.stateVersion = "22.11";
}
