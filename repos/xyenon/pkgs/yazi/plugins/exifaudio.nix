{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "exifaudio";
  version = "0-unstable-2025-06-08";

  src = fetchFromGitHub {
    owner = "Sonico98";
    repo = "exifaudio.yazi";
    rev = "e766cd273246612fe71fc18d2126619a41273c32";
    hash = "sha256-aniuY14pXcoaW6YkUwt7hTl9mWjl5HoOPhHkuY4ooAw=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Preview audio files metadata on yazi";
    homepage = "https://github.com/Sonico98/exifaudio.yazii";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
