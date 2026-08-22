# This overlay puts all the packages into nur.repos.ifd3f, so it can
# be included over an existing NUR overlay.

final: prev: {
  nur = final.lib.recursiveUpdate prev {
    repos.ifd3f = import ./default.nix { pkgs = prev; };
  };
}
