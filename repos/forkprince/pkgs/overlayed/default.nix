{
  fetchPnpmDeps,
  stdenvNoCC,
  overlayed,
  fetchurl,
  pnpm_10,
  unzip,
  lib,
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation (lib.helper.mkDarwin {
    pname = "overlayed";
    inherit (ver) version;

    src = fetchurl (lib.helper.getSingle ver);

    nativeBuildInputs = [unzip];

    meta = {
      description = "Modern discord voice chat overlay";
      homepage = "https://github.com/overlayeddev/overlayed";
      changelog = "https://github.com/overlayeddev/overlayed/releases/tag/v${ver.version}";
      maintainers = with lib.maintainers; [Prinky];
      license = lib.licenses.agpl3Plus;
    };
  })
else
  (overlayed.override {
    pnpm_9 = pnpm_10;
  }).overrideAttrs (old: {
    pnpmDeps = fetchPnpmDeps {
      inherit (old) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-JUhjJaSSveB6p2aMPRDhmShIYdUpvzTfd7vfsTDmV8k=";
    };
  })
