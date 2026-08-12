{ stdenv, fetchFromGitHub, ... }:
stdenv.mkDerivation rec {
  name = "bootstrap3";
  version = "2022-07-27";
  src = fetchFromGitHub {
    owner = "giterlizzi";
    repo = "dokuwiki-template-bootstrap3";
    rev = "v${version}";
    hash = "sha256-B3Yd4lxdwqfCnfmZdp+i/Mzwn/aEuZ0ovagDxuR6lxo=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
