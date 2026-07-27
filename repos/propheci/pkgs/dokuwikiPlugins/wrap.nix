{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "wrap";
  version = "2023-08-13";

  src = fetchzip {
    url = "https://github.com/selfthinker/dokuwiki_plugin_wrap/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-my7XW/Blyj6PLZJqs3MX3kRWXpInB913gYZnQ70v9Rs=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
