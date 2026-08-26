{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "narumitw-pi-extensions";
  version = "0-unstable-2026-08-26";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    rev = "5113b0d753ee3a021f03bf10cf82c6af28897b88";
    hash = "sha256-QP1QN1anKrYf+49OhRH7yTG7OfLOBw4KLdbo0iEpHpU=";
  };

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-8sTe4kdwdQdcP2O//LQt9rcK4OfscrZSo+xgrPv2bow=";

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
