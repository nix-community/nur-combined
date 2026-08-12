{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "mathjax";
  version = "fccaddf67d3ec51b3fc8f78db024f5f050ef0149";

  src = fetchzip {
    url = "https://github.com/liffiton/dokuwiki-plugin-mathjax/archive/${version}.zip";
    hash = "sha256-lHFRa2R8A5cKOSORsG75ZwE6XhBqAkNzfRFNdc3oW0k=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}

