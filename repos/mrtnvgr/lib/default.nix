{ pkgs }: rec {
  colors = {
    hex = import ./colors/hex.nix { inherit pkgs; };
  };

  strings = import ./strings.nix { inherit pkgs; };

  numbers = import ./numbers.nix { inherit pkgs; };

  lists = import ./lists.nix { inherit pkgs numbers; };
}
