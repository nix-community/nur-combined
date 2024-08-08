{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "reshade-shaders";
  version = "0-unstable-2024-08-07";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "a3381308e1c86fb0806bead2f4c70f5125f95a14";
    hash = "sha256-3s1mrxS3HLigRk/Q/fL8HklM2lzqJfrdaH2dK2TOIYg=";
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
