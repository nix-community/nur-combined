{ lib, pkgs, ... }:

let
  inherit (lib) makeBinPath;

  nur = import ../../nur.nix { inherit pkgs; };
in
{
  imports = [ nur.modules.nixpkgs-issue-55674 ];

  config = {
    # Daemon
    nix.daemonCPUSchedPolicy = "batch";
    nix.daemonIOSchedClass = "idle";

    # Storage
    nix.settings.auto-optimise-store = true;
    nix.gc = { automatic = true; options = "--delete-older-than 7d"; };
    nix.extraOptions = ''
      # Recommended by nix-direnv
      keep-outputs = true
      keep-derivations = true
    '';

    # Cache
    nix.settings.trusted-public-keys = [
      "nix-store.home.arpa:1IPrFEVB4K6/5Tokjv7lgvlxtxY2ZvL0t9Iy6ts5W4c="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    nix.settings.substituters = [
      "ssh://nix-ssh@nix-store.home.arpa?compress=true"
      "https://nix-community.cachix.org"
    ];
    nix.settings.fallback = true;

    # Distributed build
    nix.distributedBuilds = true;
    nix.settings.builders-use-substitutes = true;
    nix.buildMachines = [{ hostName = "nix-store.home.arpa"; sshUser = "nix-ssh"; system = "x86_64-linux"; }];

    # Validation
    # TODO: systemd.enableStrictShellChecks = true;

    # Diff after rebuild (pending NixOS/nixpkgs#208902)
    system.activationScripts.diff = ''
      PATH="${makeBinPath [ pkgs.nix ]}" \
        ${pkgs.nvd}/bin/nvd diff '/run/current-system' "$systemConfig"
    '';

    # Custom packages
    nixpkgs.overlays = [ (import ../packages.nix) ];
  };
}
