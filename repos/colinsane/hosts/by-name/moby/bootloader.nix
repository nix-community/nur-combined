# tow-boot: <https://tow-boot.org>
# docs (pinephone specific): <https://github.com/Tow-Boot/Tow-Boot/tree/development/boards/pine64-pinephoneA64>
# LED and button behavior is defined here: <https://github.com/Tow-Boot/Tow-Boot/blob/development/modules/tow-boot/phone-ux.nix>
# - hold VOLDOWN: enter recovery mode
#   - LED will turn aqua instead of yellow
#   - recovery mode would ordinarily allow a selection of entries, but for pinephone i guess it doesn't do anything?
# - hold VOLUP: force it to load the OS from eMMC?
#   - LED will turn blue instead of yellow
# boot LEDs:
# - yellow = entered tow-boot
# - 10 red flashes => poweroff means tow-boot couldn't boot into the next stage (i.e. distroboot)
#   - distroboot: <https://source.denx.de/u-boot/u-boot/-/blob/v2022.04/doc/develop/distro.rst>)
{ config, pkgs, ... }:
{
  # we need space in the GPT header to place tow-boot.
  # only actually need 1 MB, but better to over-allocate than under-allocate
  sane.image.extraGPTPadding = 16 * 1024 * 1024;
  sane.image.firstPartGap = 0;
  sane.image.installBootloader = ''
    dd if=${pkgs.tow-boot-pinephone}/Tow-Boot.noenv.bin of=$out/nixos.img bs=1024 seek=8 conv=notrunc
  '';
}
