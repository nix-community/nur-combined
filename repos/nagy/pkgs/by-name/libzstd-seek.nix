{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libzstd-seek";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "martinellimarco";
    repo = "libzstd-seek";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cBq1n4X+9hxCqj3oieP5bAKBzVjuf3hBepX29bO9QI4=";
  };

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=YES" ];

  patchPhase = ''
    runHook prePatch

    echo "install(TARGETS zstd-seek)" >> CMakeLists.txt
    echo "install(FILES zstd-seek.h DESTINATION include/)" >> CMakeLists.txt

    runHook postPatch
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ zstd ];

  meta = {
    description = "Library that mimic fread, fseek and ftell for reading zstd compressed files";
    homepage = "https://github.com/martinellimarco/libzstd-seek";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
