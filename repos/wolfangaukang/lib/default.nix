{ inputs }:

rec {
  # FIXME: WIP
  #generateFjWrappedBinConfig = import ./generateFirejail.nix { inherit inputs; };
  mkNixos = import ./mkNixos.nix { inherit inputs mkNixosHome; };
  mkNixosHome = import ./mkNixosHome.nix { inherit inputs; };
  mkHome = import ./mkHome.nix { inherit inputs; };
}
