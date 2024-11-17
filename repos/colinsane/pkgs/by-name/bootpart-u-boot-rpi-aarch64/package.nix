{ stdenv
, ubootRaspberryPi4_64bit
, raspberrypifw
, raspberrypi-armstubs
}:

stdenv.mkDerivation rec {
  pname = "bootpart-u-boot-rpi-aarch64";
  version = "1";

  buildInputs = [
    ubootRaspberryPi4_64bit
    raspberrypifw  # for bootcode.bin, *.dat, *.elf, *.dtb
    raspberrypi-armstubs  # for armstub*

  ];

  src = ./config.txt;

  dontUnpack = true;

  installPhase = ''
    mkdir "$out"
    cp ${ubootRaspberryPi4_64bit}/u-boot.bin "$out"/
    cp ${ubootRaspberryPi4_64bit}/*.dtb "$out"/
    # NB: raspberrypifw dtb's are meant for the kernel, not for u-boot
    # cp -R ${raspberrypifw}/share/raspberrypi/boot/*.dtb "$out"/
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

