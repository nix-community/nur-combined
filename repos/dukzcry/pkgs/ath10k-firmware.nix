{
  stdenvNoCC,
  fetchurl,
  lib,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ath10k-firmware";
  version = "20230622";

  src = fetchurl {
    url = "https://github.com/kvalo/ath10k-firmware/raw/master/QCA6174/hw3.0/4.4.1/firmware-6.bin_WLAN.RM.4.4.1-00309-";
    hash = "sha256-BNO61e+j+fvjulP9PiX6mwWF7SJ+6oERMDtOCIYfl50=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/lib/firmware/ath10k/QCA6174/hw3.0
    cp $src $out/lib/firmware/ath10k/QCA6174/hw3.0/firmware-6.bin
  '';

  # Firmware blobs do not need fixing and should not be modified
  dontFixup = true;

  meta = with lib; {
    description = "ath10k firmware";
    homepage = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git";
    license = licenses.unfreeRedistributableFirmware;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
