{
  lib, stdenv,
  fetchFromGitHub,
  cmake,
  ...
} @ args:

stdenv.mkDerivation rec {
  pname = "liboqs";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "liboqs";
    rev = "${version}";
    sha256 = "0i9cagzc1bsshccz3hb3sh3i3b5yj7k337dmflwf933lklxwf3pp";
  };

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DOQS_BUILD_ONLY_LIB=1"
    "-DOQS_USE_OPENSSL=OFF"
    "-DOQS_DIST_BUILD=ON"
  ];

  meta = with lib; {
    description = "C library for prototyping and experimenting with quantum-resistant cryptography";
    homepage    = "https://openquantumsafe.org";
    license = with licenses; [ mit ];
    broken = !stdenv.hostPlatform.isx86_64;
  };
}
