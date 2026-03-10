{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-03-09";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "aeafd7c65ef079ec8232fb4f17889604004f1601";
      hash = "sha256-BhbGMF6TMEKwTVxyF7nrWMwkVHdrafso97jOux8epaA=";
    };

    cargoHash = "sha256-GaIitsTwsNXb/14WYGsIgwUuGWNxHJBExoIy4w2QeI4=";
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
