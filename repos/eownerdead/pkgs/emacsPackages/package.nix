{ pkgs }:
with pkgs; {
  # https://github.com/nix-community/fenix/blob/47ac04d42227141940ed77b4f4f1c336f99f1d99/flake.nix#L48-L81
  type = "derivation";
  name = "dummy";

  eglot-tempel = callPackage ./eglot-tempel {
    inherit (pkgs.emacs.pkgs) trivialBuild eglot tempel;
  };
}
