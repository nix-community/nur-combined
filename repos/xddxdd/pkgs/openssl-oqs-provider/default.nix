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
    (python3.withPackages (p: with p; [ jinja2 pyyaml tabulate ]))
  ];

  buildInputs = [
    liboqs
    openssl_3_0
  ];

  preConfigure = ''
    cp ${sources.openssl-oqs.src}/oqs-template/generate.yml oqs-template/generate.yml
    sed -i "s/enable: false/enable: true/g" oqs-template/generate.yml
    LIBOQS_SRC_DIR=${sources.liboqs.src} python oqs-template/generate.py
  '';

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
