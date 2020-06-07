{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "libutf";
  version = "git";
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));
  prePatch = ''sed -i "s@/usr/local@$out@" config.mk'';
}
