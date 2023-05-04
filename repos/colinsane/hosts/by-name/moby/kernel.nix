{ lib, pkgs, ... }:
let
  # use the last commit on the 5.18 branch (5.18.14)
  # manjaro's changes between kernel patch versions tend to be minimal if any.
  manjaroBase = "https://gitlab.manjaro.org/manjaro-arm/packages/core/linux/-/raw/25bd828cd47b1c6e09fcbcf394a649b89d2876dd";
  manjaroPatch = name: sha256: {
    inherit name;
    patch = pkgs.fetchpatch {
      inherit name;
      url = "${manjaroBase}/${name}?inline=false";
      inherit sha256;
    };
  };

  # the idea for patching off Manjaro's kernel comes from jakewaksbaum:
  # - https://git.sr.ht/~jakewaksbaum/pi/tree/af20aae5653545d6e67a459b59ee3e1ca8a680b0/item/kernel/default.nix
  # - he later abandoned this, i think because he's using the Pinephone Pro which received mainline support.
  manjaroPatches = [
    (manjaroPatch
      "1001-arm64-dts-allwinner-add-hdmi-sound-to-pine-devices.patch"
      "sha256-DApd791A+AxB28Ven/MVAyuyVphdo8KQDx8O7oxVPnc="
    )
    # these patches below are critical to enable wifi (RTL8723CS)
    # - the alternative is a wholly forked kernel by megi/megous:
    #   - https://xnux.eu/howtos/build-pinephone-kernel.html#toc-how-to-build-megi-s-pinehpone-kernel
    # - i don't know if these patches are based on megi's or original
    (manjaroPatch
      "2001-Bluetooth-Add-new-quirk-for-broken-local-ext-features.patch"
      "sha256-CExhJuUWivegxPdnzKINEsKrMFx/m/1kOZFmlZ2SEOc="
    )
    (manjaroPatch
      "2002-Bluetooth-btrtl-add-support-for-the-RTL8723CS.patch"
      "sha256-dDdvOphTcP/Aog93HyH+L9m55laTgtjndPSE4/rnzUA="
    )
    (manjaroPatch
      "2004-arm64-dts-allwinner-enable-bluetooth-pinetab-pinepho.patch"
      "sha256-o43P3WzXyHK1PF+Kdter4asuyGAEKO6wf5ixcco2kCQ="
    )
    # XXX: this one has a Makefile, which hardcodes /sbin/depmod:
    # - drivers/staging/rtl8723cs/Makefile
    # - not sure if this is problematic?
    (manjaroPatch
      "2005-staging-add-rtl8723cs-driver.patch"
      "sha256-6ywm3dQQ5JYl60CLKarxlSUukwi4QzqctCj3tVgzFbo="
    )
  ];
in
{
  # use Megi's kernel:
  # even with the Manjaro patches, stock 5.18 has a few issues on Pinephone:
  # - no battery charging
  # - phone rotation sensor is off by 90 degrees
  # - ambient light sensor causes screen brightness to be shakey
  # - phosh greeter may not appear after wake from sleep
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.linux-megous;

  # alternatively, use nixos' kernel and add the stuff we want:
  # # cross-compilation optimization:
  # boot.kernelPackages =
  #   let p = (import nixpkgs { localSystem = "x86_64-linux"; });
  #   in p.pkgsCross.aarch64-multiplatform.linuxPackages_5_18;
  # # non-cross:
  # # boot.kernelPackages = pkgs.linuxPackages_5_18;

  # boot.kernelPatches = manjaroPatches ++ [
  #   (patchDefconfig kernelConfig)
  # ];
}
