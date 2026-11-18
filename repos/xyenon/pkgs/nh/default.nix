{
  lib,
  nh,
  nh-unwrapped ? null,
  source,
  rustPlatform,
}:

let
  base = if nh-unwrapped != null then nh-unwrapped else nh;
in
base.overrideAttrs (
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
