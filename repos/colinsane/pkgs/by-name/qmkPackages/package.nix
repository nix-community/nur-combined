{
  lib,
  newScope,
}:
lib.recurseIntoAttrs (lib.makeScope newScope (self: with self; {
  mkQmkFirmware = { keyboard ? "all", keymap ? "all" }:
    callPackage ./firmware.nix {
      inherit keyboard keymap;
    };

  all = mkQmkFirmware { };
  ergodox_ez = mkQmkFirmware { keyboard = "ergodox_ez"; };
  ergodox_ez_glow = mkQmkFirmware { keyboard = "ergodox_ez/glow"; };
  ergodox_ez_glow_sane = mkQmkFirmware { keyboard = "ergodox_ez/glow"; keymap = "sane"; };
}))
