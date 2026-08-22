{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-extensions";
  version = "0-unstable-2026-08-22";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    rev = "25ad2d64334333a08bb6d24fad193ee0ace3bdd7";
    hash = "sha256-RbeRK+mIXmCytav9OFrWLk3hMXJByYYzwtCrR3q0hCc=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-otx+K00izo0hGmr551yglxnlMm+3DHBxukoGK3+glsQ=";

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
