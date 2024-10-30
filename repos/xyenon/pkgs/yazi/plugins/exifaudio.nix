{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "exifaudio";
  version = "0-unstable-2024-10-22";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "855ff055c11fb8f268b4c006a8bd59dd9bcf17a7";
    hash = "sha256-8f1iG9RTLrso4S9mHYcm3dLKWXd/WyRzZn6KNckmiCc=";
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
