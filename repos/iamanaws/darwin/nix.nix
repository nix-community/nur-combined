{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../lib/nix-caches.nix
    ../lib/nix-store-policy.nix
  ];

  nix = {
    enable = true;
    # stable gets broken on unstable for aarch64-darwin
    package = pkgs.lixPackageSets.latest.lix;
    settings = {
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [ "@admin" ];
      extra-platforms = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };

    # Redundant with auto-optimise-store
    # optimise.automatic = config.nix.enable;

    gc = {
      automatic = config.nix.enable;
      options = "--delete-older-than 14d";
      interval = [ { Hour = 2; } ];
    };
  };
  nixpkgs.overlays = [
    (_: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
}
