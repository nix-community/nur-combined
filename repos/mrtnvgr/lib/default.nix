{ pkgs }: {
  colors = {
    hex = import ./colors/hex.nix { inherit pkgs; };
  };
}
