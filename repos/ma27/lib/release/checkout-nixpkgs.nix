{ channel, overlays ? [] }:

rec {
  packageSet = import (
    fetchTarball "https://github.com/nixos/nixpkgs-channels/archive/nixos-${channel}.tar.gz"
  );

  nixpkgsArgs = {
    config.allowUnfree = true;
    config.inHydra = true;

    inherit overlays;
  };

  invoke = overrides: packageSet (nixpkgsArgs // overrides);
}
