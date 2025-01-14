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
  version = "0-unstable-2024-11-25";

  src = fetchFromGitHub {
    owner = "trzy";
    repo = "Supermodel";
    rev = "d043dc0c6a99f5fff87d7044e85a608508eae7e1";
    hash = "sha256-/tYlvHu/IbWBbjE3F0s9QpPqZIQe/QCGiwiXk8S0J8k=";
  };

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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
