{
  lib, stdenv,
  sources,
  cmake,
  ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.liboqs) pname version src;

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DOQS_BUILD_ONLY_LIB=1"
    "-DOQS_USE_OPENSSL=OFF"
  ] ++ (if stdenv.hostPlatform.isx86_64 then [
    "-DOQS_DIST_BUILD=ON"
  ] else [
    # Disable OQS_DIST_BUILD or it fails with some "target specific option mismatch" error
    "-DOQS_DIST_BUILD=OFF"
    "-DOQS_OPT_TARGET=generic"
  ]);

  meta = with lib; {
    description = "C library for prototyping and experimenting with quantum-resistant cryptography";
    homepage    = "https://openquantumsafe.org";
    license = with licenses; [ mit ];
  };
}
