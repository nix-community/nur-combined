# notably, euicc-manual provides $out/share/doc/euicc-manual/docs/pkg/ci/manifest.json
# and $out/share/doc/euicc-manual/docs/pki/eum/manifest.json
# which are used by lpac
{
  fetchgit,
  fetchFromGitea,
  hugo,
  lib,
  stdenv,
  unstableGitUpdater,
}:
let
  self = stdenv.mkDerivation
{
  pname = "euicc-manual";
  version = "0-unstable-2025-05-14";

  # XXX: their gitea downloads are broken, so use fetchgit
  src = fetchgit {
    url = "https://gitea.osmocom.org/sim-card/euicc-manual";
    rev = "5d8365a0078cc12366e2e8a1d9958e8b155e8208";
    hash = "sha256-Wm6pofa3cjYY1mS6czzjoeX4lICXzsV6gil0qu5v/RI=";
  };

  nativeBuildInputs = [
    hugo
  ];

  buildPhase = ''
    hugo
  '';

  installPhase = ''
    mkdir -p $out/share/doc/
    cp -Rv public $out/share/doc/euicc-manual
  '';

  passthru = {
    updateScript = unstableGitUpdater { };
    ci_manifest = "${self}/share/doc/euicc-manual/docs/pki/eum/manifest.json";
    eum_manifest = "${self}/share/doc/euicc-manual/docs/pki/ci/manifest.json";
  };

  meta = with lib; {
    description = "Osmocom eUICC and eSIM Developer Manual";
    homepage = "https://euicc-manual.osmocom.org";
    repo = "https://gitea.osmocom.org/sim-card/euicc-manual";
    maintainers = with maintainers; [ colinsane ];
  };
};
in self
