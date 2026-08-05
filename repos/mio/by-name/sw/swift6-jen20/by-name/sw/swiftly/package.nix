{
  lib,
  fetchFromGitHub,
  fetchSwiftPMDeps,
  libarchive,
  pkg-config,
  stdenv,
  swift,
  swiftpm,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swiftly";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "swiftlang";
    repo = "swiftly";
    tag = finalAttrs.version;
    hash = "sha256-VFgmgo69Q4Y8Je0SMdB3jKGt9lNoVYAaUhSuK3RUkFE=";
  };

  swiftpmDeps = fetchSwiftPMDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-rTIaafSzACVyjp/Q0NLdfUETosWfCtcWDdAAAL0/t+I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    swift
    swiftpm
  ]
  # Required for libarchive.
  ++ lib.optionals stdenv.hostPlatform.isLinux [ pkg-config ];

  buildInputs = [
    zlib
  ]
  # Swiftly requires libarchive on Linux but not Darwin.
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libarchive ];

  doCheck = false; # Too many impure tests that fail. Need a mechanism to disable just those tests.

  __structuredAttrs = true;

  meta = {
    description = "Swift toolchain installer and manager";
    mainProgram = "swiftly";
    homepage = "https://github.com/swiftlang/swiftly";
    platforms = with lib.platforms; linux ++ darwin;
    license = lib.licenses.asl20;
    teams = [ lib.teams.swift ];
  };
})
