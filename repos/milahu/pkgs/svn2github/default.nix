/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'
*/

{ lib
, pkgs
, stdenv
, fetchFromGitHub
, python3
, subversion
, gnutar
, writeShellScript
}:

let
  git = pkgs.git.override { svnSupport = true; };
in

stdenv.mkDerivation rec {
  pname = "svn2github";
  version = "2019-03-04";

  src = fetchFromGitHub {
    repo = pname;
    owner = "gabrys";
    rev = "2d4cec6fb2719e1a0d15656c320249d75c375e15";
    sha256 = "0c9335zifapawrb93igz4yi21i0ry10c42v4n4q0pvyc744hh8bh";
  };

  wrapper = writeShellScript "svn2github-wrapper" ''
    PATH=${lib.makeBinPath buildInputs}
    exec python3 ${src}/svn2github.py "$@"
  '';

  buildInputs = [ python3 subversion git gnutar ];

  installPhase = ''
    mkdir -p $out/bin
    cp ${wrapper} $out/bin/svn2github
  '';

  meta = with lib; {
    description = "Mirror SVN repositories to GitHub";
    homepage = "https://github.com/gabrys/svn2github";
    license = licenses.mit;
  };
}
