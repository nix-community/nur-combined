{ lib, stdenv, fetchFromGitHub, cmake, enableXXHSum ? false
, enableShared ? !stdenv.hostPlatform.isStatic }:

stdenv.mkDerivation rec {
  pname = "xxhash";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "Cyan4973";
    repo = "xxHash";
    rev = "v${version}";
    sha256 = "sha256-2WoYCO6QRHWrbGP2mK04/sLNTyQLOuL3urVktilAwMA=";
  };

  nativeBuildInputs = [ cmake ];

  configurePhase = ''
    mkdir build
    cmake -S . -B ./build ./cmake_unofficial \
      -DCMAKE_BUILD_TYPE=Release \
      -DXXHASH_BUILD_XXHSUM=${if enableXXHSum then "ON" else "OFF"} \
      -DBUILD_SHARED_LIBS=${if enableShared then "ON" else "OFF"} \
      -DCMAKE_INSTALL_PREFIX=$out
  '';

  buildPhase = ''
    cmake --build build -j
  '';

  installPhase = ''
    cmake --install build
  '';

  meta = with lib; {
    description = "Extremely fast non-cryptographic hash algorithm.";
    homepage = "https://cyan4973.github.io/xxHash/";
    license = licenses.bsd2;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
