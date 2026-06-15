{
  lib,
  rustPlatform,
  nixpkgs,

  sources,
  source ? sources.microfetch,
}:
nixpkgs.microfetch.overrideAttrs (
  finalAttrs: prevAttrs: {
    inherit (source) src;
    version = prevAttrs.version + lib.removePrefix "0" source.version;

    cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
