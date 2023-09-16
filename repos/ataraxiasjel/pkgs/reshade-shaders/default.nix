{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "reshade-shaders";
  version = "unstable-2023-09-14";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "384465d0287999caa6190b5ebea506200b4f4a0a";
    hash = "sha256-OYcpEKo3E5DV2Q9gNMMz7wRjHvcte/vtnaoUc8aG8Qw=";
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
