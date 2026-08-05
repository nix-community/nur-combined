{
  lib,
  stdenv,
  swift,
  swiftpm,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "test-swift-differentiation";

  src = ./src;

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/test-swift-differentiation" 4 | grep '8.0'

    runHook postInstallCheck
  '';

  doInstallCheck = true;

  meta = {
    inherit (swift.meta)
      team
      platforms
      ;
    license = lib.licenses.mit;
  };
})
