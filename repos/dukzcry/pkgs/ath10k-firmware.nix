{
  stdenvNoCC,
  fetchzip,
  lib,
}:

stdenvNoCC.mkDerivation rec {
  pname = "ath10k-firmware";
  version = "20220411";

  src = fetchzip {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-${version}.tar.gz";
    hash = "sha256-/CMcUb/+9Pik5qea/MLoxh+TD+nlhNyRHHuLkEL+wHo=";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware
    cp -r ath10k $out/lib/firmware
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
