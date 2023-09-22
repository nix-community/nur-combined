{ lib
, buildLinux
, fetchpatch
, fetchFromGitea
, pkgs
# modem_power is incompatible with eg25-manager: <https://gitlab.com/mobian1/eg25-manager/-/issues/38>
, withModemPower ? true
# something inside nixpkgs calls `override` on the kernel and passes in extra arguments
, ...
}@args:

with lib;

let
  # HOW TO UPDATE:
  # - `wget https://xff.cz/kernels/git/orange-pi-active.bundle`
  # - `git fetch torvalds`
  # - `git bundle unbundle orange-pi-active.bundle`
  # - there should be some new tag, like `refs/tags/orange-pi-6.4-20230907-1427`
  # - see: <https://xnux.eu/log/094.html>
  # OLD METHOD (pre-2023/09):
  # - `git fetch` from megous' repo (https://github.com/megous/linux.git).
  # - there should be some new tag, like `orange-pi-6.1-blah`. use that.
  # - grab VERSION/PATCHLEVEL/SUBLEVEL/EXTRAVERSION from Makefile.
  # - megi publishes release notes as the most recent commit on any release tag, so just `git show` or `git log`
  # - orange-pi is listed as the "main integration branch".
  #   - this suggests it's NOT a stable branch, only `orange-pi-X.YY-YYYYMMDD-NNNN` tags are "formal" releases
  #   - specific branches like `pp` (pinephone) are dev branches, and probably less stable.
  rev = "orange-pi-6.4-20230907-1427";
  hash = "sha256-QOF6f5u4IC3OnTaCE91w7ZXmE2b2CVkVtSD1aOM8Arg=";
  base = "6.4.15";
  # set to empty if not a release candidate, else `-rc<N>`
  rc = "";

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

    MODEM_POWER = lib.mkIf (!withModemPower) no;
    # normally a module; try inline? for vibration/haptics
    INPUT_GPIO_VIBRA = yes;
    INPUT_PWM_VIBRA = yes;
    PWM_SUN4I = yes;
    # DRM_SUN4I = yes;
    # DRM_SUN8I_MIXER = yes;
    # DRM_SUN6I_DSI = yes;

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
    {
      # enable CONFIG_WOWLAN=y within the rtl8723 bluetooth/WiFi driver
      #   (not an ordinary Kconfig option).
      # also configures the pinephone device tree to `keep-power-in-suspend` for the WiFi peripherals
      # together, this allows the WiFi chip to wake the application processor when it receives packets of interest.
      # in particular this allows WiFi calls to be received while the phone is otherwise sleeping.
      # additional userspace configuration is necessary to enable this.
      # see: <https://gist.github.com/Peetz0r/bf8fd93a60962b4afcf2daeb4305da40>
      # see: <https://xnux.eu/log/031.html>
      # see: <https://irclog.whitequark.org/linux-sunxi/2021-02-19>
      name = "enable-wowlan-in-rtl8723cs";
      # patch = fetchpatch {
      #   url = "https://gist.githubusercontent.com/Peetz0r/bf8fd93a60962b4afcf2daeb4305da40/raw/7697bc9c36d75cc1a44dc164b60412a34a8bf2c4/enable-wowlan-in-rtl8723cs.patch";
      #   hash = "sha256-jXe3dHBHggdGKN8cHH4zqY9HLtZ2axXcgYO//6j9qIY=";
      # };
      patch = fetchpatch {
        url = "https://git.uninsane.org/colin/linux/commit/afd6514fd3098047000b3f1f198c2256478dce46.patch";
        hash = "sha256-8OtGXpCPJbk3c3Z4DcurS0F+Ogqx+xahEv+256+4dcY=";
      };
    }
  ] ++ lib.optionals (!withModemPower) [
    {
      # Drop modem-power from DT to allow eg25-manager to have full control.
      # source: <https://github.com/NixOS/mobile-nixos/pull/573>
      name = "remove-modem-power-from-devicetree";
      patch = fetchpatch {
        url = "https://gitlab.com/postmarketOS/pmaports/-/raw/164e9f010dcf56642d8e6f422a994b927ae23f38/device/main/linux-postmarketos-allwinner/0007-dts-pinephone-drop-modem-power-node.patch";
        sha256 = "nYCoaYj8CuxbgXfy5q43Xb/ebe5DlJ1Px571y1/+lfQ=";
      };
    }
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

  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "linux";
    inherit rev hash;
  };

  kernelPatches = extraKernelPatches ++ (
    # this patch only applies to nixpkgs kernel (and is probably not necessary on megi's).
    # TODO: remove the patch and this logic here once fixed in nixpkgs: <https://github.com/NixOS/nixpkgs/issues/255803>
    lib.filter
      (p: p.name != "backport-nfs4-selinux-fix")
      (args.kernelPatches or [])
  );

  structuredExtraConfig = (args.structuredExtraConfig or {}) // kernelConfig;
})
