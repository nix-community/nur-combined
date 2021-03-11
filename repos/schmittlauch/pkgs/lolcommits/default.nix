{ nixpkgs ? import <nixpkgs> { }, lib ? nixpkgs.lib, bundlerApp ? nixpkgs.bundlerApp
, makeWrapper ? nixpkgs.makeWrapper, mplayer ? nixpkgs.mplayer
, imagemagick ? nixpkgs.imagemagick }:

bundlerApp {
  pname = "lolcommits";
  gemdir = ./.;
  exes = [ "lolcommits" ];
  buildInputs = [ makeWrapper mplayer imagemagick ];

  postBuild = ''
    wrapProgram $out/bin/lolcommits --prefix PATH : ${
      lib.makeBinPath [ mplayer imagemagick ]
    }
  '';
}
