{
  lib,
  stdenv,
  swift,
  swiftpm,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "test-foundation-macros";

  src = ./src;

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    "$out/bin/test-foundation-macros" | grep 'Hello, foundation macros'

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
