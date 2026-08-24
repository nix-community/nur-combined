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
  version = "3.0.3";
  src = fetchFromGitHub {
    owner = "gost-engine";
    repo = "engine";
    tag = "v3.0.3";
    fetchSubmodules = true;
    hash = "sha256-52nt0TtPDpMjC0QCTrWYUhpHXZNCDrds0LrkQdDN1Mo=";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];

  cmakeFlags = [
    "-DOPENSSL_ENGINES_DIR=${placeholder "out"}/lib/ossl-engine"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
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
