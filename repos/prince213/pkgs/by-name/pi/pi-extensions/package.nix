{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-extensions";
  version = "0-unstable-2026-08-18";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    rev = "df8b78055a203dbb3d571b5b15ad08b13ec12b68";
    hash = "sha256-o4gjtcs8w24G/1kgf3dsgbObik75MKawrIiMXko65Fg=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-pSCGXM/b5TsDekM/6t907BozOpC+ijYvm1/nO8gZHZ4=";

  postInstall = ''
    cp -r $out/lib/node_modules/pi-extensions/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Pi extensions and reusable extension libraries";
    homepage = "https://github.com/narumiruna/pi-extensions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
