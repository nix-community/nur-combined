{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-03-02";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "4df030686d2075d7a07abf17bc64a8fe203ca782";
      hash = "sha256-nD78kKULpT+RGrPpVXWBzjnFRx7VrUhsCNnPJZMVBaQ=";
    };

    cargoHash = "sha256-BLv69rL5L84wNTMiKHbSumFU4jVQqAiI1pS5oNLY9yE=";
    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) pname src;
      hash = finalAttrs.cargoHash;
    };

    env = (prevAttrs.env or { }) // {
      NH_REV = finalAttrs.src.rev;
    };

    passthru = (prevAttrs.passthru or { }) // {
      updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
    };

    meta = prevAttrs.meta // {
      homepage = "https://github.com/XYenon/nh";
      maintainers = with lib.maintainers; [ xyenon ];
    };
  }
)
