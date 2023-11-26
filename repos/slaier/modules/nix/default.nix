{ inputs, config, lib, options, ... }:
{
  nix.settings = {
    auto-allocate-uids = true;
    auto-optimise-store = true;
    connect-timeout = 5;
    experimental-features = "auto-allocate-uids cgroups nix-command flakes";
    flake-registry = "/etc/nix/registry.json";
    stalled-download-timeout = 10;
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://slaier.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "slaier.cachix.org-1:NyXPOqlxuGWgyn0ApNHMopkbix3QjMUAcR+JOjjxLtU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    use-cgroups = true;
  };

  nix.gc = {
    automatic = true;
    dates = "Wed *-*-* 12:00:00";
    options = "--delete-older-than 5d";
    persistent = false;
  };

  nix.extraOptions = lib.mkIf (options.sops ? secrets) ''
    !include ${config.sops.secrets.nix_access_token.path}
  '';

  sops.secrets.nix_access_token = {
    mode = "0440";
    group = config.users.groups.keys.name;
  };

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
  ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.stateVersion = "23.05";
}
