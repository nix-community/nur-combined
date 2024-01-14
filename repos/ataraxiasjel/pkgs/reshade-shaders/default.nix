{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation rec {
  pname = "reshade-shaders";
  version = "unstable-2024-01-13";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "8b32d09e09127a1cb372fe867d5dcf8f2ddb29b2";
    hash = "sha256-XIlBHuJVUybfGX/+/CI1By3Jy2Rl3BvjRzPH03+q/zk=";
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
