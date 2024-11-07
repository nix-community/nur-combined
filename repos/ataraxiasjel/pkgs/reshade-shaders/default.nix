{
  stdenv,
  lib,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "reshade-shaders";
  version = "0-unstable-2024-11-05";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "757209bb7d00224ce36fed59dd197e04ede43973";
    hash = "sha256-8l49MfLEy2LJnStMrpgaUWfVVT6D8K6vnCtPivnO6/0=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/reshade/{shaders,textures}
    cp -r Shaders/*.*  $out/share/reshade/shaders/
    cp -r Textures/*.* $out/share/reshade/textures/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "A collection of post-processing shaders written for ReShade";
    homepage = "https://github.com/crosire/reshade-shaders";
    platforms = platforms.all;
    license = licenses.unlicense;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
