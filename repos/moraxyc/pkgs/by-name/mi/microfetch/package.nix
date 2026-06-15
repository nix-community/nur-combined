{
  lib,
  stdenv,
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

    patches =
      (prevAttrs.patches or [ ])
      ++ lib.optional stdenv.hostPlatform.isLoongArch64 ./0001-fix-desktop-avoid-LoongArch-crash-from-manual-String.patch;

    passthru = (prevAttrs.passthru or { }) // {
      _ignoreOverride = true;
    };
  }
)
