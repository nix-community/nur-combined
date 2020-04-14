{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "gruvbox-css";
  version = "latest";
  src = fetchFromGitHub {
    owner = "Xe";
    repo = name;
    rev = "6e1841c94190a1e06e63a2596767e66c35671320";
    sha256 = "0s7whnin63558i70wp3by3rydsdx0qdzh5553km1s29w81npmgj6";
  };
  phases = "installPhase";
  installPhase = ''
    mkdir -p $out
    cp -rf $src/gruvbox.css $out/gruvbox.css
    cp -rf $src/snow.css $out/snow.css
  '';
}
