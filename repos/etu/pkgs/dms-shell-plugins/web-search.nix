{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-web-search";
  version = "0-unstable-2026-07-04";

  src = fetchFromGitHub {
    owner = "devnullvoid";
    repo = "dms-web-search";
    rev = "821f5b437ea96739ce1cbc85ce324fb55e8884bb";
    hash = "sha256-UqFgAjW2A75dtlvOZkq4Vv/v/DROoc/ouCXBaVlksPI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell launcher plugin to search the web with 23+ built-in search engines plus custom search engine support";
    homepage = "https://github.com/devnullvoid/dms-web-search";
    license = licenses.mit;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
