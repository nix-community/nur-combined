{
  lib,
  stdenv,
  fetchFromGitHub,
  libGLU,
  SDL2,
  SDL2_net,
  xorg,
  zlib,
  nix-update-script,

  debugBuild ? false,
  enableNetBoard ? true,
  enableDebugger ? true,
}:

stdenv.mkDerivation {
  pname = "supermodel";
  version = "0-unstable-2025-03-22";

  src = fetchFromGitHub {
    owner = "trzy";
    repo = "Supermodel";
    rev = "90b5bfcc1781d0922e91f246f865ccc18e94f4d8";
    hash = "sha256-lk9jeCSWKnRVy4P90mab8W6F+oAlP8nk0aaJp542UFk=";
  };

  nativeBuildInputs = [
    SDL2 # sdl2-config
  ];

  buildInputs = [
    libGLU
    SDL2
    SDL2_net
    xorg.libX11
    zlib
  ];

  makefile = "Makefiles/Makefile.UNIX";

  makeFlags =
    lib.optional debugBuild "DEBUG=1"
    ++ lib.optional enableNetBoard "NET_BOARD=1"
    ++ lib.optional enableDebugger "ENABLE_DEBUGGER=1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/supermodel $out/bin

    runHook postInstall
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=format-security";

  strictDeps = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "supermodel";
    description = "Sega Model 3 arcade machine emulator";
    homepage = "https://github.com/trzy/Supermodel";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
