{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "boringssl-oqs";
  version = "2021-08-snapshot";

  src = pkgs.fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "boringssl";
    rev = "935d651e73a8f1e74b80dcbddede175f46ab216d";
    sha256 = "03648hc4if12imrsahrlsw5s2x821hl2jxk7vs7cdjjmlw0h97r6";
  };

  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";

  enableParallelBuilding = true;

  liboqs = pkgs.callPackage ../liboqs {};

  nativeBuildInputs = [
    pkgs.cmake
    pkgs.ninja
    pkgs.perl
    pkgs.pkgconfig
  ];

  buildInputs = [
    liboqs
  ];

  cmakeFlags = [
    "-GNinja"
    "-DCMAKE_BUILD_TYPE=Release"
  ];

  preBuild = ''
    export HOME=$TMP
    ln -s ${liboqs} oqs
    cmakeConfigurePhase
  '';

  buildPhase = ''
    ninjaBuildPhase
  '';

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
