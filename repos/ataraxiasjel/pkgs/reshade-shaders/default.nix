{ stdenv
, lib
, fetchFromGitHub
, nix-update-script
}:

stdenv.mkDerivation {
  pname = "reshade-shaders";
  version = "unstable-2024-03-01";

  src = fetchFromGitHub {
    owner = "crosire";
    repo = "reshade-shaders";
    rev = "ce462207e0830fa7f57ed5e81a1c5d450c6e4791";
    hash = "sha256-flSz+6TV6MkdSz+xLnVe0HxhEVDL6MCHrPzWJWleoZ0=";
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
