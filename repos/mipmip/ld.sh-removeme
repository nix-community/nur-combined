export NIX_LD=$(nix eval --impure --raw --expr '
      let
        pkgs = import <nixpkgs> {};
        NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
      in NIX_LD
      ')
