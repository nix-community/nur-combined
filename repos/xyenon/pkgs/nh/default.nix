{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-03-15";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "605ade361500cf5618818a4a5e8a54fe8d1c3006";
      hash = "sha256-Hbt7/qK7yupdHBfd4LQ6d1mh4d9PvLw49zhdUQxXHxE=";
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
      homepage = "https://github.com/XYenon/nh";
      maintainers = with lib.maintainers; [ xyenon ];
    };
  }
)
