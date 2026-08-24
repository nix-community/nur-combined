{
  lib,
  stdenv,
  fetchFromGitHub,

  catch2_3,
  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "valentine";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "tote-bag-labs";
    repo = "valentine";
    rev = "v${finalAttrs.version}";
    hash = "sha256-l/rwSnvPizRsWBle9YaVIadVuWJlqLy4UycvmGLITt8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  cmakeFlags = [ "-DFETCHCONTENT_SOURCE_DIR_CATCH2=${catch2_3.src}" ];

  meta = {
    description = "An open source compressor meant to pump and breathe";
    homepage = "https://github.com/tote-bag-labs/valentine";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "Valentine";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
