{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:
let
  images = import ../../images {
    inherit system pkgs;
  };

  containers = map (i: {
    name = i.name;
    path = pkgs.dockerTools.buildImage {
      name = i.name;
      fromImage = i.value;
    };
  }) (pkgs.lib.attrsToList images);

in
pkgs.linkFarm "images" containers
