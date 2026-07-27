{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "color";
  version = "2022-10-19";

  src = fetchzip {
    url = "https://github.com/hanche/dokuwiki_color_plugin/archive/refs/tags/${version}.zip";
    hash = "sha256-B9HX6uj9Y2i2QAH8Tznynhl1m0JSEEPAtYycmaUcRkQ=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
