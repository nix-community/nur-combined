{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  cmake,
  openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gost-engine";
  version = "3.0.5";
  src = fetchFromGitHub {
    owner = "gost-engine";
    repo = "engine";
    tag = "v${finalAttrs.version}";
    fetchSubmodules = true;
    hash = "sha256-9RJMLWghYLJmk6TTsweKPOjEnM0GbgLZL4ErLIxO6a4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];

  patches = [ ./relax-openssl-root.patch ];

  cmakeFlags = [
    (lib.cmakeFeature "OPENSSL_ENGINES_DIR" "${placeholder "out"}/lib/ossl-engine")
    (lib.cmakeFeature "CMAKE_POLICY_VERSION_MINIMUM" "3.5")
    (lib.cmakeFeature "OPENSSL_ROOT_DIR" "${lib.getDev openssl}")
    (lib.cmakeFeature "OPENSSL_CRYPTO_LIBRARY" "${lib.getLib openssl}/lib/libcrypto.so")
    (lib.cmakeFeature "OPENSSL_SSL_LIBRARY" "${lib.getLib openssl}/lib/libssl.so")
  ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/gost-engine/engine/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Reference implementation of the Russian GOST crypto algorithms for OpenSSL";
    homepage = "https://github.com/gost-engine/engine";
    license = lib.licenses.asl20;
    mainProgram = "gostsum";
  };
})
