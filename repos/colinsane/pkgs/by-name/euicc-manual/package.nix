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
  version = "0-unstable-2024-12-09";

  # XXX: their gitea downloads are broken, so use fetchgit
  src = fetchgit {
    url = "https://gitea.osmocom.org/sim-card/euicc-manual";
    rev = "ab97957e2004ffb64a50d6175e61121b9d4138ce";
    hash = "sha256-u2L/+kbaV5F9ef84Za+KF/hgJYlJ5R07i2eVb9FDUyI=";
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
