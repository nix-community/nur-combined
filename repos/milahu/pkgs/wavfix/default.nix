# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

{ fetchFromGitHub, pkg-config, pkgs, fetchurl, lib, stdenv }:
stdenv.mkDerivation rec {
  pname = "wavfix";
  version = "git-2021-04-24";
  sourceRoot = "source";

  #src = builtins.path { name = "source"; path = ./wavfix; }; # local version
  #/*
  src = fetchFromGitHub {
    repo = "wavfix";
    #owner = "agfline";
    #rev = "v${version}";
    owner = "milahu";
    rev = "41e454410d5de8285b6cb17ba0670e0542a40fed";
    sha256 = "04w8dsbsp1sc15jl32ndgaz0jg542f3kshapli3kw5jzp89f9k0q";
    name = "source";
  };
  #*/

  makeFlags  = [
    "PREFIX=${placeholder "out"}"
  ];
  meta = with lib; {
    description = "Repair broken wav files while preserving metadata";
    homepage = "https://github.com/agfline/wavfix";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
