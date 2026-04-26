{
  # keep-sorted start
  fetchFromGitHub,
  lib,
  mkYaziPlugin,
  # keep-sorted end
}:
mkYaziPlugin rec {
  pname = "spot-image.yazi";
  version = "0-unstable-2026-04-25";

  src = fetchFromGitHub {
    owner = "AminurAlam";
    repo = "yazi-plugins";
    rev = "8ed61d7c0cc1902963f59020d3c87f505adc8273";
    hash = "sha256-KEz/o1Sk5hydzMSje/2u80hnuBnUyDxnMhyT00T4zQI=";
  };

  installPhase = ''
    runHook preInstall

    cp -rL ${pname} $out

    runHook postInstall
  '';

  meta = {
    # keep-sorted start
    description = "image metadata and exif";
    homepage = "https://github.com/AminurAlam/yazi-plugins/tree/main/spot-image.yazi";
    license = lib.licenses.gpl3Only;
    # keep-sorted end
  };
}
