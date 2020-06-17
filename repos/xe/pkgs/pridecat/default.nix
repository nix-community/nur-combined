{ stdenv, fetchFromGitHub, libX11, libXinerama, libXft }:

let
  pname = "pridecat";
  version = "git";
in stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  prePatch = ''sed -i "s@/usr/local@$out@" Makefile'';
  preInstall = "mkdir -p $out/bin";
}
