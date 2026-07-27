{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "graphviz";
  version = "2016-02-03";

  src = fetchzip {
    url = "https://github.com/splitbrain/dokuwiki-plugin-graphviz/archive/refs/tags/${version}.zip";
    hash = "sha256-xMp2ttOjt7LxP+m/aYBmAOjCSrocZPwQxP8Sxd/fZbs=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
