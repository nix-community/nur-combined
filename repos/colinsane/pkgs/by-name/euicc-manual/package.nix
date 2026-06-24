# notably, euicc-manual provides $out/share/doc/euicc-manual/docs/pkg/ci/manifest.json
# and $out/share/doc/euicc-manual/docs/pki/eum/manifest.json
# which are used by lpac
{
  fetchgit,
  hugo,
  lib,
  stdenvNoCC,
  unstableGitUpdater,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "euicc-manual";
  version = "0-unstable-2025-11-21";

  # XXX: their gitea downloads are broken, so use fetchgit
  src = fetchgit {
    url = "https://gitea.osmocom.org/sim-card/euicc-manual";
    rev = "2f9be0aa4e41e8f1b95b5cccef47e461bd674adb";
    hash = "sha256-lHD/E9+uArZggh/eQCvtXbSrwtCg0aMyW/P8yn7blhE=";
  };

  nativeBuildInputs = [
    hugo
  ];

  buildPhase = ''
    runHook preBuild

    hugo

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/doc/
    cp -Rv public $out/share/doc/euicc-manual

    runHook postInstall
  '';

  installCheckPhase = ''
    runHook preInstallCheck

    (
      set -x
      test -f $out/${finalAttrs.passthru.ci_manifest_path}
      test -f $out/${finalAttrs.passthru.eum_manifest_path}
    )

    runHook postInstallCheck
  '';

  doInstallCheck = true;

  passthru = rec {
    skipBulkUpdate = true;  #< XXX(2026-03-15): no future version passes installCheck, but also this package is now an unused leaf node.
    updateScript = unstableGitUpdater { };
    ci_manifest_path = "share/doc/euicc-manual/docs/pki/ci/manifest.json";
    ci_manifest = "${finalAttrs.finalPackage}/${ci_manifest_path}";
    eum_manifest_path = "share/doc/euicc-manual/docs/pki/eum/manifest-v2.json";
    eum_manifest = "${finalAttrs.finalPackage}/${eum_manifest_path}";
  };

  meta = {
    description = "Osmocom eUICC and eSIM Developer Manual";
    homepage = "https://euicc-manual.osmocom.org";
    repo = "https://gitea.osmocom.org/sim-card/euicc-manual";
    maintainers = with lib.maintainers; [ colinsane ];
  };
})
