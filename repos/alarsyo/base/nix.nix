{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    trustedUsers = [ "@wheel" ];

    binaryCaches = [
      "https://alarsyo.cachix.org"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "alarsyo.cachix.org-1:A6BmcaJek5+ZDWWv3fPteHhPm6U8liS9CbDbmegPfmk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    gc = {
      automatic = true;
      dates = "03:15";
      options = "--delete-older-than 30d";
    };
  };
}
