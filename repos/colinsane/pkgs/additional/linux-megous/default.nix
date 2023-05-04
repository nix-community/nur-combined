{ lib
, buildLinux
, buildPackages
, fetchFromGitHub
, modDirVersionArg ? null
, nixosTests
, perl
, pkgs
, ...
} @ args:

with lib;

let
  # HOW TO UPDATE:
  # - `git fetch` from megous' repo (https://github.com/megous/linux.git).
  # - there should be some new tag, like `orange-pi-6.1-blah`. use that.
  # - megi publishes release notes as the most recent commit on any stable branch, so just `git log`.
  # - orange-pi is listed as the "main integration branch".
  #   - specific branches like `pp` (pinephone) are dev branches, and probably less stable.
  rev = "orange-pi-6.2-20230122-1624";
  hash = "sha256-Yma9LwlMEnP0QkUZpEl+UkTGvOWOMANBoDsmcTrPb1s=";
  base = "6.2.0";
  # set to empty if not a release candidate
  rc = "-rc5";

  # pinephone uses the linux dtb at arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtsi
  # - this includes sun50i-a64.dtsi
  # - and sun50i-a64-cpu-opp.dtsi
  # - no need to touch the allwinner-h6 stuff: that's the SBC pine product
  # - i think it's safe to ignore sun9i stuff, but i don't know what it is
  kernelConfig = with lib.kernel; {
    # NB: nix adds the CONFIG_ prefix to each of these.
    # if you add the prefix yourself nix will IGNORE YOUR CONFIG.
    RTL8723CS = module;
    BT_HCIUART_3WIRE = yes;
    BT_HCIUART_RTL = yes;
    RTL8XXXU_UNTESTED = yes;
    BT_BNEP_MC_FILTER = yes;
    BT_BNEP_PROTO_FILTER = yes;
    BT_HS = yes;
    BT_LE = yes;
    #
    ### BUILD FIXES, NOT SPECIFIC TO MY PREFERENCES
    #
    # disabling the sun5i_eink driver avoids this compilation error:
    # CC [M]  drivers/video/fbdev/sun5i-eink-neon.o
    # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfloat-abi=softfp'
    # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfpu=neon'
    # make[3]: *** [../scripts/Makefile.build:289: drivers/video/fbdev/sun5i-eink-neon.o] Error 1
    FB_SUN5I_EINK = no;
    # used by the pinephone pro, but fails to compile with:
    # ../drivers/media/i2c/ov8858.c:1834:27: error: implicit declaration of function 'compat_ptr'
    VIDEO_OV8858 = no;
    #
    ### RELEVANT CONFIGS INHERITED FROM NIXOS DEFAULTS (OR ABOVE ADDITIONS):
    #
    # CONFIG_BT=m
    # CONFIG_BT_BREDR=y
    # CONFIG_BT_RFCOMM=m
    # CONFIG_BT_RFCOMM_TTY=y
    # CONFIG_BT_BNEP=m
    # CONFIG_BT_HIDP=m
    # CONFIG_BT_RTL=m
    # CONFIG_BT_HCIBTUSB=m
    # CONFIG_BT_HCIBTUSB_BCM=y
    # CONFIG_BT_HCIBTUSB_RTL=y
    # CONFIG_BT_HCIUART=m
    # CONFIG_BT_HCIUART_SERDEV=y
    # CONFIG_BT_HCIUART_H4=y
    # CONFIG_BT_HCIUART_LL=y
    # CONFIG_RTL_CARDS=m
    # CONFIG_RTLWIFI=m
    # CONFIG_RTLWIFI_PCI=m
    # CONFIG_RTLWIFI_USB=m
    # CONFIG_RTLWIFI_DEBUG=y
    # CONFIG_RTL8723_COMMON=m
    # CONFIG_RTLBTCOEXIST=m
    # CONFIG_RTL8XXXU=m
    # CONFIG_RTLLIB=m
    # consider adding (from mobile-nixos):
    # maybe: CONFIG_BT_HCIUART_3WIRE=y
    # maybe: CONFIG_BT_HCIUART_RTL=y
    # maybe: CONFIG_RTL8XXXU_UNTESTED=y
    # consider adding (from manjaro):
    # CONFIG_BT_6LOWPAN=m  (not listed as option in nixos kernel)
    # these are referenced in the rtl8723 source, but not known to config (and not in mobile-nixos config
    # maybe: CONFIG_RTL_ODM_WLAN_DRIVER
    # maybe: CONFIG_RTL_TRIBAND_SUPPORT
    # maybe: CONFIG_SDIO_HCI
    # maybe: CONFIG_USB_HCI
  };

  # `pkgs.kernelPatches` is a set of common patches
  # while `kernelPatches` callarg is a list.
  # weird idiom, means we have to access pkgs.kernelPatches to access the actual patch directory:
  extraKernelPatches = [
    pkgs.kernelPatches.bridge_stp_helper
    pkgs.kernelPatches.request_key_helper
    (patchDefconfig kernelConfig)
  ];


  # create a kernelPatch which overrides nixos' defconfig with extra options
  patchDefconfig = config: {
    # defconfig options. this method comes from here:
    # - https://discourse.nixos.org/t/the-correct-way-to-override-the-latest-kernel-config/533/9
    name = "linux-megous-defconfig";
    patch = null;
    extraStructuredConfig = config;
  };

  overridenArgs = args // rec {
    version = base + rc;

    # modDirVersion needs to be x.y.z, will automatically add .0 if needed
    modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) + rc else modDirVersionArg;

    # branchVersion needs to be x.y
    extraMeta.branch = versions.majorMinor version;

    src = fetchFromGitHub {
      owner = "megous";
      repo = "linux";
      inherit rev hash;
    };
  } // (args.argsOverride or { });
  finalArgs = overridenArgs // {
    kernelPatches = overridenArgs.kernelPatches or [] ++ extraKernelPatches;
  };
in buildLinux finalArgs
