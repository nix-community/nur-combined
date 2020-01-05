{ pkgs ? (import <nixpkgs> {}) }:
with pkgs;
stdenv.mkDerivation {
  name = "zsh-nix-shell";
  src = fetchFromGitHub {
    repo = "zsh-nix-shell";
    owner = "chisui";
    rev = "a092037e77daef06e13e708dad28a2a1ef7794b9";
    sha256 = "0rfc7wbl8nr3rzv3chff7vwnh7nyh8mvxizbm9ki0vwfbryzdj84";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    cp -a $src $out
  '';
}
