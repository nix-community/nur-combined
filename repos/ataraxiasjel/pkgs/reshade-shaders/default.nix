{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "reshade-shaders";
  version = "unstable-2024-01-15";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "fb9dcb99034759cd437610b7657307d52f8086ff";
    hash = "sha256-8uj6BVOHU/OTwD3uW5KuZH0Hu6wjmzzulfVm0a8HWok=";
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
