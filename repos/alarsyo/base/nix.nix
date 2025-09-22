{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.lixPackageSets.latest.lix;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 60d";
      persistent = true;
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];
      substituters = [
        "https://alarsyo.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "alarsyo.cachix.org-1:A6BmcaJek5+ZDWWv3fPteHhPm6U8liS9CbDbmegPfmk="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
