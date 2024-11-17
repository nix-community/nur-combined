{ pkgs ? import <nixpkgs> {
  overlays = [ (import ../../overlays/pkgs.nix) ]; }
}:

let
  mx-sanebot = pkgs.callPackage ./. { };
in
  pkgs.mkShell {
    nativeBuildInputs = mx-sanebot.buildInputs ++ mx-sanebot.nativeBuildInputs ++ [
      pkgs.cargo
    ];

    # Allow cargo to download crates.
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  }
