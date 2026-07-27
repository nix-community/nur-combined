{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "comment";
  version = "2023-08-18";

  src = fetchzip {
    url = "https://github.com/dokufreaks/plugin-comment/archive/refs/tags/${version}.zip";
    hash = "sha256-6y1B/nWe7IY008phsu5qHbGfU9DlrFn/W7azLBYmJ4k=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
