{ lib
, fetchFromGitLab
, stdenv
, zip
}:

stdenv.mkDerivation rec {
  pname = "bypass-paywalls-clean";
  version = "3.2.5.0";
  src = fetchFromGitLab {
    owner = "magnolia1234";
    repo = "bypass-paywalls-firefox-clean";
    rev = "v${version}";
    hash = "sha256-FkAqzJisPdBiElX9ceQS3zfg8zwrsozOquHDagiRKiE=";
  };

  patches = [
    ./0001-dont-show-options.patch
    ./0002-disable-auto-update.patch
    ./0003-disable-metrics.patch
  ];

  installPhase = ''
    ${zip}/bin/zip -r $out ./*
  '';

  passthru = {
    extid = "magnolia@12.34";
  };

  meta = {
    homepage = "https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean";
    description = "Add-on allows you to read articles from (supported) sites that implement a paywall.";
    license = with lib.licenses; [ mit ];
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
