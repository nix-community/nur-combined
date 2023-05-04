{ stdenv, tow-boot-rpi4, raspberrypifw, raspberrypi-armstubs }:

stdenv.mkDerivation rec {
  pname = "bootpart-tow-boot-rpi-aarch64";
  version = "1";

  buildInputs = [
    tow-boot-rpi4  # for Tow-Boot.*.bin
    raspberrypifw  # for bootcode.bin, *.dat, *.elf, *.dtb
    raspberrypi-armstubs  # for armstub*
  ];

  src = ./config.txt;

  dontUnpack = true;

  installPhase = ''
    mkdir "$out"
    cp ${tow-boot-rpi4}/Tow-Boot.noenv.*.bin "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/*.dtb "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/*.bin "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/*.dat "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/*.img "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/*.elf "$out"/
    cp -R ${raspberrypifw}/share/raspberrypi/boot/overlays "$out"/
    cp ${raspberrypi-armstubs}/* "$out"/
    cp ${src} "$out"/config.txt
  '';


  meta = {
    description = "unmanaged files to place in /boot on a raspberry pi system";
    platforms = [ "aarch64-linux" ];
  };
}

