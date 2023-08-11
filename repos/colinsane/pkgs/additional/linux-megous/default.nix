{ lib
, buildLinux
, fetchFromGitHub
, pkgs
# something inside nixpkgs calls `override` on the kernel and passes in extra arguments
, ...
}@args:

with lib;

let
  # HOW TO UPDATE:
  # - `git fetch` from megous' repo (https://github.com/megous/linux.git).
  # - there should be some new tag, like `orange-pi-6.1-blah`. use that.
  # - grab VERSION/PATCHLEVEL/SUBLEVEL/EXTRAVERSION from Makefile.
  # - megi publishes release notes as the most recent commit on any release tag, so just `git show` or `git log`
  # - orange-pi is listed as the "main integration branch".
  #   - this suggests it's NOT a stable branch, only `orange-pi-X.YY-YYYYMMDD-NNNN` tags are "formal" releases
  #   - specific branches like `pp` (pinephone) are dev branches, and probably less stable.
  rev = "orange-pi-6.4-20230619-0323";
  hash = "sha256-il32UQM/8Fc7VHft3+M4TLMxk5+h28C9Suu1kRdZj2M=";
  base = "6.4.0";
  # set to empty if not a release candidate, else `-rc<N>`
  rc = "-rc7";

  # pinephone uses the linux dtb at arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtsi
  # - this includes sun50i-a64.dtsi
  # - and sun50i-a64-cpu-opp.dtsi
  # - no need to touch the allwinner-h6 stuff: that's the SBC pine product
  # - i think it's safe to ignore sun9i stuff, but i don't know what it is
  kernelConfig = with lib.kernel; {
    # NB: nix adds the CONFIG_ prefix to each of these.
    # if you add the prefix yourself nix will IGNORE YOUR CONFIG.

    # optimize for faster builds.
    # see <repo:kernel.org/linux:Documentation/admin-guide/quickly-build-trimmed-linux.rst>
    DEBUG_KERNEL = lib.mkForce no;  # option group which seems to just gate the other DEBUG_ opts?
    DEBUG_INFO = lib.mkForce no;  # for gdb debugging
    DEBUG_INFO_BTF = lib.mkForce no;  # BPF debug symbols. rec by <https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage>
    SCHED_DEBUG = lib.mkForce no;  # determines /sys/kernel/debug/sched
    # SUNRPC_DEBUG = lib.mkForce no;  # i use NFS though

    # taken from mobile-nixos config?? or upstream megous config??
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
    # (patchDefconfig kernelConfig)
  ];


  # create a kernelPatch which overrides nixos' defconfig with extra options
  # patchDefconfig = config: {
  #   # defconfig options. this method comes from here:
  #   # - https://discourse.nixos.org/t/the-correct-way-to-override-the-latest-kernel-config/533/9
  #   name = "linux-megous-defconfig";
  #   patch = null;
  #   extraStructuredConfig = config;
  # };

in buildLinux (args // {
  version = base + rc;

  # modDirVersion needs to be x.y.z, where `z` could be `Z-rcN`
  # nix kernel build will sanity check us if we get the modDirVersion wrong
  modDirVersion = base + rc;

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor base;

  src = fetchFromGitHub {
    owner = "megous";
    repo = "linux";
    inherit rev hash;
  };

  kernelPatches = (args.kernelPatches or []) ++ extraKernelPatches;

  structuredExtraConfig = (args.structuredExtraConfig or {}) // kernelConfig;
})
