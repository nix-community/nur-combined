{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "exifaudio";
  version = "0-unstable-2024-10-15";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "d75db468e89ab379992c21cb745ca7920d5f409f";
    hash = "sha256-ECo0rTDF+oqRtRsqrhBuVdZtEpJShRk/XXhPwEy4cfE=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Preview audio files metadata on yazi";
    homepage = "https://github.com/Sonico98/exifaudio.yazii";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
