{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "boringssl-oqs";
  version = "2021-08";

  src = pkgs.fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "boringssl";
    rev = "OQS-BoringSSL-snapshot-${version}";
    sha256 = "1d22vyjr041hng0b9g4i6lcjw1zj94g6zws48f0ki9r3c8r1svdy";
  };

  enableParallelBuilding = true;

  liboqs = pkgs.callPackage ../liboqs {};

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.go
    pkgs.perl
    pkgs.pkgconfig
  ];

  buildInputs = [
    pkgs.libunwind
    liboqs
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  preConfigure = ''
    ln -s ${liboqs} oqs
  '';

  preBuild = ''
    export HOME=$TMP
    export GOCACHE=$TMP/go-cache
    export GOPATH=$TMP/go
  '';

  buildFlags = [
    "crypto"
    "ssl"
    "bssl"
    "decrepit"
  ];

  installPhase = ''
    mkdir -p $out/bin $out/include $out/lib
    mv tool/bssl              $out/bin
    mv ssl/libssl.a           $out/lib
    mv crypto/libcrypto.a     $out/lib
    mv decrepit/libdecrepit.a $out/lib
    mv ../include/openssl $out/include
  '';

  meta = with pkgs.lib; {
    description = "Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs";
    homepage    = "https://openquantumsafe.org";
    license = with licenses; [ openssl isc mit bsd3 ];
  };
}
