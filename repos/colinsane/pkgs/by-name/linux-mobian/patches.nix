{
  fetchFromGitLab,
  lib,
  newScope,
}:
lib.makeScope newScope (self: with self; {
  src = fetchFromGitLab {
    domain = "salsa.debian.org";
    owner = "Mobian-team/devices/kernels";
    repo = "sunxi64-linux";
    rev = "mobian/6.6.51+sunxi64-1";
    hash = "sha256-RcALbQ5df2vjyRrr5IKR6rR5Uyk9iHEpDYVtMP5lxzM=";
  };

  pinephone = with self.pinephone; {
    # make an entry for `boot.kernelPatches` from a sanitized commit message
    getByName = name: {
      inherit name;
      patch = "${src}/debian/patches/pinephone/${name}.patch";
    };

    # e.g. `byName.0132-regulator-axp20x-Turn-N_VBUSEN-to-input-on-x-powers` is a valid kernel patch
    byName = lib.genAttrs patchNames getByName;

    # ordered patches
    series = builtins.map getByName patchNames;
    patchNames = [
      "0132-regulator-axp20x-Turn-N_VBUSEN-to-input-on-x-powers-"
      "0133-arm64-dts-sun50i-a64-pinephone-Add-front-back-camera"
      "0134-arm64-dts-sun50i-a64-pinephone-Add-Type-C-support-fo"
      "0135-arm64-dts-sun50i-a64-pinephone-Add-detailed-OCV-to-c"
      "0136-arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-"
      "0137-arm64-dts-sun50i-a64-pinephone-Add-support-for-Bluet"
      "0138-arm64-dts-sun50i-a64-pinephone-Enable-internal-HMIC-"
      "0139-arm64-dts-sun50i-a64-pinephone-Add-support-for-modem"
      "0140-arm64-dts-sun50i-a64-pinephone-Bump-I2C-frequency-to"
      "0141-arm64-dts-sun50i-a64-pinephone-Add-interrupt-pin-for"
      "0142-arm64-dts-sun50i-a64-pinephone-Don-t-make-lradc-keys"
      "0143-arm64-dts-sun50i-a64-pinephone-Add-supply-for-i2c-bu"
      "0144-arm64-dts-sun50i-a64-pinephone-Workaround-broken-HDM"
      "0145-arm64-dts-sun50i-a64-pinephone-Add-AF8133J-to-PinePh"
      "0146-arm64-dts-sun50i-a64-pinephone-Add-mount-matrix-for-"
      "0147-arm64-dts-sun50i-a64-pinephone-Add-support-for-Pinep"
      "0148-arm64-dts-sun50i-a64-Add-missing-trip-points-for-GPU"
      "0149-arm64-dts-allwinner-sun50i-a64-pinephone-Add-support"
      "0150-ARM-dts-allwinner-sun50i-64-pinephone-Add-power-supp"
      "0151-arm64-dts-sun50i-a64-pinephone-Power-off-the-touch-c"
      "0152-arm64-dts-allwinner-pinephone-Add-modem-EG25-G-suppo"
      "0153-arm64-dts-sun50i-pinephone-add-near-level-to-proximi"
      "0154-arm64-dts-allwinner-pinephone-lower-cpu_alert-temper"
      "0155-arm64-dts-allwinner-pinephone-change-backlight-brigh"
      "0156-arm64-dts-allwinner-pinephone-fix-headphone-jack-nam"
      "0157-arm64-dts-pinephone-Add-pstore-support-for-PinePhone"
      "0158-arm64-dts-allwinner-pinephone-Set-orientation-for-fr"
    ];
  };
})
