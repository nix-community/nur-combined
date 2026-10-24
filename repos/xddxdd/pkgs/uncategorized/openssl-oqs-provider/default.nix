{
  fetchFromGitHub,
  lib,
  stdenv,
  cmake,
  liboqs-unstable,
  openssl,
}:
let
  qscKeyEncoderSrc = fetchFromGitHub {
    owner = "Quantum-Safe-Collaboration";
    repo = "qsc-key-encoder";
    rev = "1b6289dac9f7caf89d26bad2f1cf3cd628507af2";
    hash = "sha256-fslq2BlNtnUve7enWXzWGc8xUh8clmHs+QjPozjinHM=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openssl-oqs-provider";
  version = "0.12.0-unstable-2026-10-24";
  src = fetchFromGitHub {
    owner = "open-quantum-safe";
    repo = "oqs-provider";
    rev = "80460d3e1476e59c177b20e8478bcc7b1afde193";
    hash = "sha256-yFORnggOU5W3BNrxgraTL6hekVDtt2ha7ZVS86UItP4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  enableParallelBuilding = true;
  dontFixCmake = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    liboqs-unstable
    openssl
  ];

  cmakeFlags = [ (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release") ];

  postPatch = ''
    cp -r ${qscKeyEncoderSrc} qsc-key-encoder
    chmod -R 755 qsc-key-encoder

    sed -i "s|GIT_REPOSITORY .*|SOURCE_DIR $(pwd)/qsc-key-encoder|g" oqsprov/CMakeLists.txt
    sed -i "/GIT_TAG .*/d" oqsprov/CMakeLists.txt
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 lib/oqsprovider.so "$out/lib/oqsprovider.so"

    runHook postInstall
  '';

  passthru.updateScript = [
    (toString ./update.sh)
  ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenSSL 3 provider containing post-quantum algorithms";
    homepage = "https://openquantumsafe.org";
    license = with lib.licenses; [ mit ];
  };
})
