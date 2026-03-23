{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-03-23";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "4a06a374384b99a4e95dbecefab6da633c3db149";
      hash = "sha256-mxBboB9Q9UKUH9feHU+2B7bPjDygp9OTpmpS/1MeJVk=";
    };

    cargoHash = "sha256-cyho/mSYUQtH0x+cD696TZhdpd0X9UrmtzsSbFfbO30=";
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
