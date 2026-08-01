{
  config,
  pkgs,
  ...
}:

{
  imports = [ ../lib/nix-caches.nix ];

  nix = {
    enable = true;
    # stable gets broken on unstable for aarch64-darwin
    package = pkgs.lixPackageSets.latest.lix;
    settings = {
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

    optimise.automatic = config.nix.enable;

    gc = {
      automatic = config.nix.enable;
      options = "--delete-older-than 14d";
      interval = [ { Hour = 2; } ];
    };

    # Run GC when there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };
  nixpkgs.overlays = [
    (final: prev: {
      inherit (prev.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
}
