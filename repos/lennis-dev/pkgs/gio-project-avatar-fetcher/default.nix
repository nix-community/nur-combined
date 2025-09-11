{
  stdenv,
  fetchgit,
  lib,
}:

stdenv.mkDerivation rec {
  name = "gio-project-avatar-fetcher-${version}";
  version = "4faa096";
  src = fetchgit {
    url = "https://gist.github.com/738dc8e374cfef1c050fe6b3cca45f59.git";
    hash = "sha256-1KsUB3LAglKg+4m6YqkmUHQEHF17N4NdXezFqxlaxRY=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ${src}/avatar_fetcher.sh $out/bin/gio-project-avatar-fetcher
    chmod +x $out/bin/gio-project-avatar-fetcher
  '';

  meta = with lib; {
    description = "Fetches avatars for folders in ~/Projects from GitHub, and displays them as folder icons";
    license = licenses.mit;
  };
}
