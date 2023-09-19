{ stdenv
, lib
, fetchgit
, anx7688 ? true  # USB-C chip (pinephone)
, ov5640 ? true   # camera (pinephone: rear camera)
, rtl_bt ? true   # rtl8723cs bluetooth (pinephone)
# other files in megi's repo:
# - brcm/
#   - brcmfmac43362-*
#   - brcmfmac43455-sdio-*: BCM43455 WiFi/BT (raspberry pi 4b)
#   - brcmfmac43456-*
# - hm5065-*.bin:  5 MP sensor used in the pine devboards (likely not in the phones)
# - regulatory.db
# - rockchip/dptx.bin
# - rtlwifi/rtl8188eufw.bin
# - rtw88/rtw8822c-*.bin
# - rtw89/rtw8852a_fw.bin
}:
stdenv.mkDerivation {
  name = "linux-firmware-megous";
  version = "unstable-2023-2023-05-06";
  src = fetchgit {
    url = "https://megous.com/git/linux-firmware";
    rev = "0510074346983ad33b3d52ce8f5d6a8f89a564a8";
    hash = "sha256-qZVkGv4PCqKSYz92yy0+9oZY7dPW24rmj5obeaVXt0Y=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/lib/firmware"
    ${lib.optionalString rtl_bt "cp -R rtl_bt $out/lib/firmware"}
    ${lib.optionalString anx7688 "cp anx7688-fw.bin $out/lib/firmware"}
    ${lib.optionalString ov5640 "cp ov5640_af.bin $out/lib/firmware"}
  '';

  meta = with lib; {
    description = "firmware files associated with megi's kernel, particularly for the pinephone";
    homepage = "https://xnux.eu/howtos/build-pinephone-kernel.html#toc-firmware-files";
  };
}
