{
  callPackage,
  lib,
  path,
  rustPlatform,
}:
let
  # Import the original definition directly to avoid recursing through this overlay.
  herdr = callPackage "${path}/pkgs/by-name/he/herdr/package.nix" { };
  patch = ../patches/fcitx5-prefix-niri.patch;
in
assert lib.assertMsg (
  herdr.version == "0.9.1"
) "Rebase the Fcitx5 prefix patch before updating Herdr";
herdr.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ patch ];

  # Vendor the patched lockfile as well as applying the runtime changes.
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (old) pname version src;
    patches = (old.cargoPatches or [ ]) ++ [ patch ];
    hash = "sha256-d9GcQEzGGNlFFONTNfAQ+P93TqiM6pHOvwUncLTSdbw=";
  };
})
