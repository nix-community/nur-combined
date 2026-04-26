{ inputs, config, lib, options, ... }:
{
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = "cgroups nix-command flakes";
    flake-registry = "/etc/nix/registry.json";
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
    extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
  };

  nix.gc = {
    automatic = true;
    dates = "Wed *-*-* 12:00:00";
    options = "--delete-older-than 5d";
    persistent = false;
  };

  nix.extraOptions = lib.mkIf (options ? sops) ''
    !include ${config.sops.secrets.nix_access_token.path}
  '';

  nix.nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "nixpkgs-unstable=${inputs.nixpkgs-unstable}"
  ];
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.registry.nixpkgs-unstable.flake = inputs.nixpkgs-unstable;

  nixpkgs.config = {
    allowUnfree = true;
    npmRegistryOverridesString = builtins.toJSON {
      "registry.npmjs.org" = "https://mirrors.cloud.tencent.com/npm";
    };
  };

  programs.ccache = {
    enable = true;
    cacheDir = "/nix/var/cache/ccache";
    packageNames = [
      "llama-cpp"
    ];
  };

  system.stateVersion = "25.11";
}
