# after building a firmware image (.hex/.elf/.uf2 file),
# flash it to a plugged-in keyboard using wally or pico bootloader:
# - `nix-build -A qmkPackages.ergodox_ez`
# - `wally-cli ./result/share/qmk/ergodox_ez.hex`
{ mkQmkFirmware }:
mkQmkFirmware {
  keyboard = "ergodox_ez";
}
