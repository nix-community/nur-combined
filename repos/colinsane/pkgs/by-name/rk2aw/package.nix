{
  fetchurl,
  linkFarmFromDrvs,
}: (linkFarmFromDrvs "rk2aw" [
  (fetchurl {
    name = "README";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/README";
    hash = "sha256-vpfoNIAjQffAsN8tcAfCgwUEkf9C9QUIfv36WWCDLKo=";
  })
  (fetchurl {
    name = "INSTALL";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/INSTALL";
    hash = "sha256-5coi9kHxDryHcfzqhyAbIMgho0CeWlEt1prji8I7blk=";
  })
  (fetchurl {
    name = "debug.img";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/debug.img";
    hash = "sha256-aAKh1FWrodmtLPCFP/1//MTkOD6k9Uflm/0iXNbNQ3U=";
  })
  (fetchurl {
    name = "debug.img.spi";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/debug.img.spi";
    hash = "sha256-i/v+RBUb/ttYHYlUoLYI4BgJ9MV5djvQGmBXwsdxhYA=";
  })
  (fetchurl {
    name = "normal.img";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/normal.img";
    hash = "sha256-15JhtWIPUJ1KW+0tKiEZtChsEmOURxC/y1n1+PdaaJw=";
  })
  (fetchurl {
    name = "normal.img.spi";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/normal.img.spi";
    hash = "sha256-J+2uirGbo6JV4l0Dh0U8NY4oiCx1CmvkqZgzYHECAwA=";
  })
  (fetchurl {
    # aarch64-only
    name = "rk2aw-spi-flasher";
    url = "https://xff.cz/kernels/rk2aw/rk2aw-rk3399-pinephone-pro/rk2aw-spi-flasher";
    hash = "sha256-knYWVuplkHVyU/w6ftfpO+MCLMFNIWX6jO8wdqBsIC0=";
  })
]).overrideAttrs {
  meta.description = ''rk2aw loader program can be used on various modern Rockchip SoCs to change apparent boot ROM bootloader load order from original and inflexible "SPI NOR flash -> eMMC -> SD card" to "SD card -> eMMC -> SPI NOR flash" and to implement robust, seamless A/B bootloader updates in SPI NOR flash with user selectable fallback (via a pre-boot menu)'';
  meta.homepage = "https://xnux.eu/rk2aw/";
}
