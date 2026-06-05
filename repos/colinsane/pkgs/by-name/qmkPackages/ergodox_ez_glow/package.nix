# after building a firmware image (.hex/.elf/.uf2 file),
# flash it to a plugged-in keyboard using wally or pico bootloader:
# - `nix-build -A qmkPackages.ergodox_ez_glow`
# - `wally-cli ./result/share/qmk/ergodox_ez_glow.hex`
{ mkQmkFirmware }:
mkQmkFirmware {
  keyboard = "ergodox_ez/glow";
  keymap = "default";
}
