{ pkgs, inputs, config, settings, ... }:
{
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://slaier.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "slaier.cachix.org-1:NyXPOqlxuGWgyn0ApNHMopkbix3QjMUAcR+JOjjxLtU="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    auto-optimise-store = true;
    flake-registry = "/etc/nix/registry.json";
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    min-free = ${toString ((settings.nix-min-free or (30 * 1024)) * 1024 * 1024)}
    max-free = ${toString ((settings.nix-max-free or (100 * 1024)) * 1024 * 1024)}
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

  nix.package = pkgs.nix-nss-mdns;

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.stateVersion = "23.05";
}
