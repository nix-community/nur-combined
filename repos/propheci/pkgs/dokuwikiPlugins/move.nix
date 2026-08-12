{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "move";
  version = "2024-05-07";

  src = fetchzip {
    url = "https://github.com/michitux/dokuwiki-plugin-move/archive/refs/tags/${version}.zip";
    sha256 = "sha256-wi9doC1AmC/vBjuooOsh4+hQWdH66MEiIjZdW9e03g0=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
