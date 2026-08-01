{
  inputs,
  lib,
  ...
}:

{
  imports = [ ../../lib/nix-caches.nix ];

  nix = {
    settings = {
      auto-optimise-store = true;
      builders-use-substitutes = true;
      keep-outputs = true;
      # bash-prompt = "";

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      substituters = [
        "https://cache.dataaturservice.se/spectrum/"
        # "https://nix-community.cachix.org"
        # "https://nix-gaming.cachix.org"
      ];

      trusted-public-keys = [
        "spectrum-os.org-2:foQk3r7t2VpRx92CaXb5ROyy/NBdRJQG2uX2XJMYZfU="
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        # "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];

      trusted-users = [ "@wheel" ];
    };

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
      persistent = true;
      randomizedDelaySec = "45min";
    };

    # Run GC when there is less than 100MiB left.
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  environment.variables = {
    # force builds to use nix daemon, also if user is root
    NIX_REMOTE = "daemon";
    # fix nixpkgs path for nix-shell -p
    NIX_PATH = lib.mkForce "nixpkgs=${inputs.nixpkgs}";
  };

}
