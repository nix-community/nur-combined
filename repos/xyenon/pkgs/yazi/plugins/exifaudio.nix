{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "exifaudio";
  version = "0-unstable-2025-02-27";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "4379fcfa2dbe0b81fde2dd67b9ac2e0e48331419";
    hash = "sha256-CIimJU4KaKyaKBuiBvcRJUJqTG8pkGyytT6bPf/x8j8=";
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
