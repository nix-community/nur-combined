{
  lib,
  nh-unwrapped,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "4.3.0-unstable-2026-03-17";

    src = fetchFromGitHub {
      owner = "XYenon";
      repo = "nh";
      rev = "98ad645dc185e6db8ff324c49773c08acd4acdd9";
      hash = "sha256-NIqdQ4xZ7ov8ljVKJv6yIHkP3U2zjG5JrFKalPdh+Qo=";
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
