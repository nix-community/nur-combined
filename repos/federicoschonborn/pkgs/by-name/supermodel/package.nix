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
  version = "0-unstable-2024-07-19";

  src = fetchFromGitHub {
    owner = "trzy";
    repo = "Supermodel";
    rev = "5fa402f2f586ebd7a107e68f7b9d9613e56d2b70";
    hash = "sha256-viL3c+/Xj/YcAMxstUUWxvhKENzWCbw3Qhb1lxEIA18=";
  };

  buildInputs = [
    libGLU
    SDL2
    SDL2_net
    xorg.libX11
    zlib
  ];

  makeFlags =
    [
      "-f"
      "Makefiles/Makefile.UNIX"
    ]
    ++ lib.optional debugBuild "DEBUG=1"
    ++ lib.optional enableNetBoard "NET_BOARD=1"
    ++ lib.optional enableDebugger "ENABLE_DEBUGGER=1";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp bin/supermodel $out/bin

    runHook postInstall
  '';

  env.NIX_CFLAGS_COMPILE = "-Wno-error=format-security";

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
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
