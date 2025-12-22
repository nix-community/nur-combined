{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "twltool";
  version = "1.7-unstable-2024-01-21";

  src = fetchFromGitHub {
    owner = "WinterMute";
    repo = pname;
    rev = "09e17699473b26474afcf30a9d0f7ec8aba10fbf";
    hash = "sha256-xjDZaIleQfx7uTXoc1wP0vcefibndkd+CYpx6bbzPWQ=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp twltool${stdenv.hostPlatform.extensions.executable} $out/bin
    runHook postInstall
  '';

  meta = with lib; {
    description = "Nintendo DSi multitool";
    homepage = "https://github.com/WinterMute/twltool";
    mainProgram = "twltool";
    platforms = platforms.all;
  };
}
