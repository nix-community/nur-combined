{ lib
, fetchFromGitLab
, gitUpdater
, stdenv
, zip
}:

stdenv.mkDerivation rec {
  pname = "bypass-paywalls-clean";
  version = "3.3.6.0";
  src = fetchFromGitLab {
    owner = "magnolia1234";
    repo = "bypass-paywalls-firefox-clean";
    rev = "v${version}";
    hash = "sha256-5v5jsOdTMVnCFXBnRXrbkOrevoxpf9SoEpEsl9Pe7j8=";
  };

  patches = [
    ./0001-dont-show-options.patch
    ./0002-disable-auto-update.patch
    ./0003-disable-metrics.patch
  ];

  nativeBuildInputs = [ zip ];

  installPhase = ''
    zip -r $out ./*
  '';

  passthru = {
    extid = "magnolia@12.34";
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
    description = "Add-on allows you to read articles from (supported) sites that implement a paywall.";
    license = with lib.licenses; [ mit ];
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
