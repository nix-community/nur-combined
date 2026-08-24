{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  cmake,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "clap-info";
  version = "1.2.2";
  src = fetchFromGitHub {
    owner = "free-audio";
    repo = "clap-info";
    rev = "v${finalAttrs.version}";
    hash = "sha256-H2Nxx+p8uxm82qJbwfkKlAzyJkqC7c5tIexgghv38cY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  postPatch = ''
    substituteInPlace libs/clap/clap.pc.in \
      --replace '$'"{prefix}/@CMAKE_INSTALL_INCLUDEDIR@" '@CMAKE_INSTALL_FULL_INCLUDEDIR@'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp clap-info $out/bin

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A tool to show information about a CLAP plugin on the command line";
    homepage = "https://github.com/free-audio/clap-info";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-info";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
