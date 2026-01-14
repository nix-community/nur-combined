{
  sources,
  version,
  lib,
  stdenv,
  clangStdenv,
  stdenvAdapters,
  cmake,
  yasm,
  ninja,
  cpuinfo,
  libdovi,
  hdr10plus,
}:
let
  adapters = lib.optionals (!stdenv.targetPlatform.isDarwin) [
    stdenvAdapters.useMoldLinker
  ];
  customStdenv = lib.pipe clangStdenv adapters;
in
customStdenv.mkDerivation (finalAttrs: {
  inherit (sources) pname src;
  inherit version;

  cmakeBuildType = "Release";

  cmakeFlags =
    lib.mapAttrsToList
      (
        n: v:
        lib.cmakeOptionType (builtins.typeOf v) n (
          if builtins.isBool v then lib.boolToString v else toString v
        )
      )
      {
        LIBDOVI_FOUND = true;
        LIBHDR10PLUS_RS_FOUND = true;
        CMAKE_INTERPROCEDURAL_OPTIMIZATION = true;
      };

  nativeBuildInputs = [
    cmake
    ninja
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    yasm
  ];

  buildInputs = [
    libdovi
    hdr10plus
  ]
  ++ lib.optionals stdenv.hostPlatform.isx86_64 [
    cpuinfo
  ];

  meta = {
    homepage = "https://github.com/${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    description = "Scalable Video Technology AV1 Encoder and Decoder";
    license = with lib.licenses; [
      aom
      bsd3
    ];
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      ccicnce113424
    ];
    mainProgram = "SvtAv1EncApp";
  };
})
