{ pkgs }: {
  colors = {
    hex = import ./colors/hex.nix { inherit pkgs; };
  };

  strings = import ./strings.nix { inherit pkgs; };
}
