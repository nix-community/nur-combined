{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-04-06";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "35831951e9b4b8fe32d6bff378c1123446245831";
      hash = "sha256-rxZdWYgRyIaQ3hCW2NXX90PsSrYRK91DrQBqOhPuz4o=";
    };

    cargoHash = "sha256-mNB6XGMLQ8fHFegJouL3I2M2Ng+4x3YnXn3eOAf60jQ=";
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
      changelog = "https://github.com/XYenon/nh/blob/master/CHANGELOG.md";
      homepage = "https://github.com/XYenon/nh";
      maintainers = with lib.maintainers; [ xyenon ];
    };
  }
)
