{
  lib,
  nh-unwrapped,
  source,
  rustPlatform,
}:

nh-unwrapped.overrideAttrs (
  finalAttrs: prevAttrs: {
    version = "${prevAttrs.version}-unstable-${source.date}";

    inherit (source) src;

    cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

    env = (prevAttrs.env or { }) // {
      NH_REV = finalAttrs.src.rev;
    };

    meta = prevAttrs.meta // {
      changelog = "https://github.com/XYenon/nh/blob/master/CHANGELOG.md";
      homepage = "https://github.com/XYenon/nh";
      maintainers = with lib.maintainers; [ xyenon ];
    };
  }
)
