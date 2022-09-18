{ lib
, stdenv
, sources
, cmake
, liboqs
, openssl_3_0
, python3
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.openssl-oqs-provider) pname version src;

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
    # (python3.withPackages (p: with p; [ jinja2 pyyaml tabulate ]))
  ];

  buildInputs = [
    liboqs
    openssl_3_0
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  installPhase = ''
    mkdir -p $out/lib
    install -m755 oqsprov/oqsprovider.so "$out/lib"
  '';

  meta = with lib; {
    description = "OpenSSL 3 provider containing post-quantum algorithms";
    homepage = "https://openquantumsafe.org";
    license = with licenses; [ mit ];
  };
}
