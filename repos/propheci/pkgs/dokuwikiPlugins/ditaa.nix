{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "ditaa";
  version = "2016-06-24";

  src = fetchzip {
    url = "https://github.com/splitbrain/dokuwiki-plugin-ditaa/archive/refs/tags/${version}.zip";
    hash = "sha256-Y1isJ2IDD++LXzBdgNmgPaTrSlqdfUy3EzlWJk4Ik9c=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
