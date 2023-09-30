{ stdenv, lib, fetchFromGitHub, cmake, zstd }:

stdenv.mkDerivation rec {
  pname = "libzstd-seek";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "martinellimarco";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-u8TEpvs+xMW2UhNNsEQRJGc+tChZ+ibTdkcafqq45EE=";
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

  meta = with lib; {
    description =
      "Library that mimic fread, fseek and ftell for reading zstd compressed files";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.all;
  };
}
