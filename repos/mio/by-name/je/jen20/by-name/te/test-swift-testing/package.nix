{
  lib,
  stdenv,
  swift,
  swiftpm,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "test-swift-testing";

  src = ./src;

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  doCheck = true;

  meta = {
    inherit (swift.meta)
      team
      platforms
      ;
    broken = stdenv.hostPlatform.isDarwin; # Swift Testing does not currently work on Darwin due to XCTest limitations.
    license = lib.licenses.mit;
  };
})
