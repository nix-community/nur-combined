{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  images = import ../../images {
    inherit system pkgs;
  };

  all = pkgs.lib.attrsets.concatMapAttrs (
    name: value:
    pkgs.lib.filterAttrs (_: v: v != null) {
      "${name}-amd64" = value.x86_64-linux or null;
      "${name}-arm64" = value.aarch64-linux or null;
      "${name}-arm" = value.armv7l-linux or null;
    }
  ) images;

  containers = map (i: {
    name = i.name;
    path = pkgs.dockerTools.buildImage {
      name = i.name;
      fromImage = i.value;
    };
  }) (pkgs.lib.attrsToList all);

in
pkgs.linkFarm "images" containers
