# SPDX-FileCopyrightText: 2023 Unidealistic Raccoon <procyon@secureninja.maskmy.id>
# SPDX-FileCopyrightText: 2023 Elizabeth Paź <me@ehllie.xyz>
# SPDX-FileCopyrightText: 2023 Nix community projects <admin@nix-community.org>
# SPDX-FileCopyrightText: 2023 Mihai Fufezan <fufexan@protonmail.com>
#
# SPDX-License-Identifier: MIT

{ flake, lib, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.etc = {
    "nix/flake-channels/system".source = flake.self;
    "nix/flake-channels/nixpkgs".source = flake.inputs.nixpkgs;
  };

  nix = {
    optimise.automatic = true;
    nixPath = [ "nixpkgs=/etc/nix/flake-channels/nixpkgs" ];
    registry = lib.mapAttrs (_: v: { flake = v; }) flake.inputs;
    gc = {
      dates = "daily";
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = let asGB = size: toString (size * 1024 * 1024 * 1024); in {
      sandbox = true;
      min-free = asGB 10;
      max-free = asGB 50;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
