{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};

  fromYAML = pkgs.callPackage ./src/nix-yaml/from-yaml.nix { };

  toYAML = pkgs.callPackage ./src/nix-yaml/to-yaml.nix { };

}
