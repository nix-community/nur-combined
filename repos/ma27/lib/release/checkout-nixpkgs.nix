{ lib }:
{ channel, overlays ? [], trackBranches ? false, upstream ? "NixOS" }:

let

  url = "https://github.com/${upstream}/nixpkgs${lib.optionalString (!trackBranches) "-channels"}/archive/${lib.optionalString (!trackBranches) "nixos-"}${channel}.tar.gz";

in

rec {
  packageSet = import (fetchTarball url);

  nixpkgsArgs = {
    config.allowUnfree = true;
    config.inHydra = true;

    inherit overlays;
  };

  invoke = overrides: packageSet (nixpkgsArgs // overrides);
}
