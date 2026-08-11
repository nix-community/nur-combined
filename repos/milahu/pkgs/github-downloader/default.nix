/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
./result/bin/github-downloader.sh
*/

{ stdenv
, lib
, fetchFromGitHub
, bash
, subversion
, makeWrapper
}:

let
  baseVersion = "2020-06-30";
  rev = "08049f6183e559a9a97b1d144c070a36118cca97";
  sha256 = "073jkky5svrb7hmbx3ycgzpb37hdap7nd9i0id5b5yxlcnf7930r";
in

stdenv.mkDerivation {
  pname = "github-downloader";
  version = "${baseVersion}.${builtins.substring 0 7 rev}";
  src = fetchFromGitHub {
    owner = "Decad";
    repo = "github-downloader";
    inherit rev sha256;
  };
  buildInputs = [ bash subversion ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp github-downloader.sh $out/bin/github-downloader.sh
    wrapProgram $out/bin/github-downloader.sh \
      --prefix PATH : ${lib.makeBinPath [ bash subversion ]}
  '';

  meta = with lib; {
    description = "Download folders and files from github without cloning";
    homapage = "https://github.com/Decad/github-downloader";
    #license = licenses.mit; # no license
    platforms = platforms.linux;
  };
}
