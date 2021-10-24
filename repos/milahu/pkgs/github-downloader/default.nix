/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
*/

{ stdenv
, lib
, fetchFromGitHub
, bash
, subversion
, makeWrapper
}:

stdenv.mkDerivation {
  pname = "github-downloader";
  version = "08049f6";
  src = fetchFromGitHub {
    owner = "Decad";
    repo = "github-downloader";
    rev = "08049f6183e559a9a97b1d144c070a36118cca97";
    sha256 = "073jkky5svrb7hmbx3ycgzpb37hdap7nd9i0id5b5yxlcnf7930r";
  };
  buildInputs = [ bash subversion ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp github-downloader.sh $out/bin/github-downloader.sh
    wrapProgram $out/bin/github-downloader.sh \
      --prefix PATH : ${lib.makeBinPath [ bash subversion ]}
  '';
  meta = {
    homapage = "https://github.com/Decad/github-downloader";
  };
}
