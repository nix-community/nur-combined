{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "exifaudio";
  version = "0-unstable-2025-03-03";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "de526f336dfed54c8545d1e445cb8511e195fecd";
    hash = "sha256-s+WPSUfHNuS+xVgtPjjIOFMuu+mAUD6j7jsiZmZpcf0=";
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
