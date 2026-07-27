{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation {
  inherit (sources.valentine) pname src;
  version = lib.removePrefix "v" sources.valentine.version;

  nativeBuildInputs = [
    juceCmakeHook
  ];

  cmakeFlags = [ "-DFETCHCONTENT_SOURCE_DIR_CATCH2=${sources.catch2.src}" ];

  meta = {
    description = "An open source compressor meant to pump and breathe";
    homepage = "https://github.com/tote-bag-labs/valentine";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Valentine";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
