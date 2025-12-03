{
  lib,
  stdenv,
  fetchFromGitLab,
  testers,
  autoreconfHook,
  glib,
  openssl,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  # Belledonne Communications' sofia-sip fork.
  # they stopped tagging releases after 1.13.45bc (2020-11-06)
  pname = "sofia-sip-bc";
  version = "1.13.45bc-unstable-2024-08-05";

  src = fetchFromGitLab {
    domain = "gitlab.linphone.org";
    owner = "BC/public/external";
    repo = "sofia-sip";
    rev = "b924a57e8eeb24e8b9afc5fd0fb9b51d5993fe5d";
    hash = "sha256-1VbKV+eAJ80IMlubNl7774B7QvLv4hE8SXANDSD9sRU=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    glib
    openssl
  ];

  enableParallelBuilding = true;

  strictDeps = true;

  doCheck = true;  # XXX(2025-10-23): checkPhase is a no-op

  passthru = {
    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = false;  #< pc version won't match for unstable versions
    };
    # TODO: enable updateScript?
    # updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "Open-source SIP User-Agent library, compliant with the IETF RFC3261 specification";
    homepage = "https://gitlab.linphone.org/BC/public/external/sofia-sip";
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ colinsane ];
    pkgConfigModules = [
      "sofia-sip-ua"
      "sofia-sip-ua-glib"
    ];
  };
})

