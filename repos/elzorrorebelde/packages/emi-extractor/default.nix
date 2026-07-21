{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "emi-extractor";
  version = "unstable-2022-02-28";

  src = fetchFromGitHub {
    owner = "glitch-in-the-herring";
    repo = "emi-extractor";
    rev = "d92ecb83bdc982caf9834d1f362309b5a9a90efa";
    hash = "sha256-AWhC8BapG2KyR6DgGAkEmcQ02UlOUr5oX7wm4Xvzmkg=";
  };

  buildPhase = ''
    runHook preBuild

    gcc -O2 -o emi_extractor extractor.c frontend.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp emi_extractor $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Extractor for .EMI Files";
    longDescription = ''
      A tool to extract all sections from .EMI files found in Breath of Fire III
      and IV. Separates the various sections of the EMI file into multiple files.
    '';
    homepage = "https://github.com/glitch-in-the-herring/emi-extractor";
    license = licenses.mit;
    maintainers = with maintainers; [ shackra ];
    platforms = platforms.all;
    mainProgram = "emi_extractor";
  };
}
