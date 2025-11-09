{
  lib,
  stdenv,
  sources,
  cmake,
  liboqs,
  openssl_3,
  python3,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.openssl-oqs-provider) pname version src;

  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
    (python3.withPackages (
      p: with p; [
        jinja2
        pyyaml
        tabulate
      ]
    ))
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

    export LIBOQS_SRC_DIR=${sources.liboqs.src}
    sed -i "s/enable: false/enable: true/g" oqs-template/generate.yml
    sed -i "s/enable_kem: false/enable_kem: true/g" oqs-template/generate.yml
    sed -i "s/enable_tls: false/enable_tls: true/g" oqs-template/generate.yml
    python3 oqs-template/generate.py
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
