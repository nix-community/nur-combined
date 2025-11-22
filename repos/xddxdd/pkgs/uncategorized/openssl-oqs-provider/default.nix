{
  lib,
  stdenv,
  sources,
  cmake,
  liboqs,
  openssl_3,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.openssl-oqs-provider) pname version src;

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    liboqs
    openssl_3
  ];

  cmakeFlags = [ "-DCMAKE_BUILD_TYPE=Release" ];

  postPatch = ''
    cp -r ${sources.qsc-key-encoder.src} qsc-key-encoder
    chmod -R 755 qsc-key-encoder

    sed -i "s|GIT_REPOSITORY .*|SOURCE_DIR $(pwd)/qsc-key-encoder|g" oqsprov/CMakeLists.txt
    sed -i "/GIT_TAG .*/d" oqsprov/CMakeLists.txt
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 lib/oqsprovider.so "$out/lib/oqsprovider.so"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/open-quantum-safe/oqs-provider/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenSSL 3 provider containing post-quantum algorithms";
    homepage = "https://openquantumsafe.org";
    license = with lib.licenses; [ mit ];
  };
})
