{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  SDL2,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dingusppc";
  version = "Alpha103";

  src = fetchFromGitHub {
    owner = "dingusdev";
    repo = "dingusppc";
    rev = finalAttrs.version;
    hash = "sha256-Uk8FUIVbLXkmwIXPDMoWKt14hD700yP2r5fUSCHTsC8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    SDL2
  ];

  hardeningDisable = [ "format" ];

  postInstall = ''
    mkdir -p $out/bin
    mv bin/dingusppc $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "dingusppc";
    description = "Power Mac emulator for Windows, Linux and macOS";
    homepage = "https://github.com/dingusdev/dingusppc";
    changelog = "https://github.com/dingusdev/dingusppc/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
