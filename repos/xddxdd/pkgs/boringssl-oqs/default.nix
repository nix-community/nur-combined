{
  lib, stdenv, buildGoModule, fetchFromGitHub,
  cmake, ninja, perl, pkgconfig, liboqs,
  ...
} @ args:

buildGoModule rec {
  pname = "boringssl-oqs";
  version = "2021-12-rc1";

  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "boringssl";
    rev = "OQS-BoringSSL-snapshot-2021-12-rc1";
    sha256 = "sha256-Z9fdJARedL4LiVhTjg0Zz+o2jGMZOv8ScoaW5NATG3I=";
  };

  vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";

  enableParallelBuilding = true;

  nativeBuildInputs = [
    cmake
    ninja
    perl
    pkgconfig
  ];

  buildInputs = [
    liboqs
  ];

  preBuild = ''
    export HOME=$TMP
    ln -s ${liboqs} oqs
    cmakeConfigurePhase
  '';

  buildPhase = ''
    ninjaBuildPhase
  '';

  # CMAKE_OSX_ARCHITECTURES is set to x86_64 by Nix, but it confuses boringssl on aarch64-linux.
  cmakeFlags = [ "-GNinja" ] ++ lib.optionals (stdenv.isLinux) [ "-DCMAKE_OSX_ARCHITECTURES=" ];

  installPhase = ''
    mkdir -p $out/bin $out/include $out/lib
    mv tool/bssl              $out/bin
    mv ssl/libssl.a           $out/lib
    mv crypto/libcrypto.a     $out/lib
    mv decrepit/libdecrepit.a $out/lib
    mv ../include/openssl $out/include
  '';

  meta = with lib; {
    description = "Fork of BoringSSL that includes prototype quantum-resistant key exchange and authentication in the TLS handshake based on liboqs";
    homepage    = "https://openquantumsafe.org";
    license = with licenses; [ openssl isc mit bsd3 ];
  };
}
