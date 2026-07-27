{
  sources,

  lib,
  stdenv,

  cmake,
  ninja,
}:
stdenv.mkDerivation {
  inherit (sources.clap-info) pname src;
  version = lib.removePrefix "v" sources.clap-info.version;

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

  meta = {
    description = "A tool to show information about a CLAP plugin on the command line";
    homepage = "https://github.com/free-audio/clap-info";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "clap-info";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
