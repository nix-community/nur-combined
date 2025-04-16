{
  sources,
  lib,
  stdenv,
  cmake,
  openssl,
}:
stdenv.mkDerivation rec {
  inherit (sources.gost-engine) pname version src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];

  cmakeFlags = [ "-DOPENSSL_ENGINES_DIR=${placeholder "out"}/lib/ossl-engine" ];

  meta = {
    changelog = "https://github.com/gost-engine/engine/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Reference implementation of the Russian GOST crypto algorithms for OpenSSL";
    homepage = "https://github.com/gost-engine/engine";
    license = lib.licenses.asl20;
    mainProgram = "gostsum";
  };
}
