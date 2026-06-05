# after building a firmware image (.hex/.elf/.uf2 file),
# flash it to a plugged-in keyboard using wally or pico bootloader:
# - `nix-build -A qmkPackages.ergodox_ez_glow_sane`
# - `wally-cli ./result/share/qmk/ergodox_ez_glow_sane.hex`
{ mkQmkFirmware }:
mkQmkFirmware {
  keyboard = "ergodox_ez/glow";
  # XXX(2026-05-18): the ergodox_ez/glow IN PARTICULAR does not support non-default keymaps;
  # instead, use the "default" keymap and overwrite it via ./userspace :|
  keymap = "default";
  userspace = ./userspace;
}
