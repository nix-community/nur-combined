{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  cmake,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nlnet-mimir";
  version = "0-unstable-2026-01-06";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = "mimir";
    rev = "9f230b6980fc5f6844095affcb1984397449f97a";
    hash = "sha256-bMJJKOFGMm6Fzk+V2dJ39y/tvYGsayY+453RPQndD18=";
  };

  cargoHash = "sha256-mOdd58NIrEo4JU4r946KZqphm60QhPiyLuFjpGlFv08=";

  nativeBuildInputs = [ cmake ];

  env = {
    CMAKE_POLICY_VERSION_MINIMUM = "3.31";
    NIX_CFLAGS_COMPILE =
      "-Wno-error=unterminated-string-initialization"
      + lib.optionalString stdenv.buildPlatform.isLinux " -Wno-error=stringop-overflow";
  };

  meta = {
    homepage = "https://nlnetlabs.nl/projects/domain/mimir/";
    description = "DNS proxy and load balancer";
    mainProgram = "mimir";
    license = lib.licenses.mpl20;
  };
})
