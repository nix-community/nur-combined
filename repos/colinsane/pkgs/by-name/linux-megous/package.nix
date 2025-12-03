# BUILD THE CONFIG WITH:
# - `nix build '.#hostConfigs.moby.boot.kernelPackages.kernel.configfile'`
#   - note that this config is patched, based on `config.nixpkgs.hostPlatform.linux-kernel`!
#   - the host-independent config can be built with: `nix build '.#linux-megous.passthru.configfile'`
#     however this unflavored config doesn't reflect what will actually be deployed!
# QUERY THE NIX-AWARE CONFIG WITH:
# - `hostConfigs.moby.boot.kernelPackages.kernel.configfile.passthru.structuredConfig...` in the nix repl
# BUILD THE KERNEL WITH:
# - `nix build '.#hostConfigs.moby.boot.kernelPackages.kernel'`
# other people using pinephone kernels:
# - postmarketOS (pmaports)
#   - uses megi's kernel; their kernel config is embedded in their pmaports repo
{
  lib,
  buildLinux,
  fetchpatch,
  fetchFromGitea,
  newScope,
  pkgs,
# modem_power is incompatible with eg25-manager: <https://gitlab.com/mobian1/eg25-manager/-/issues/38>
  withModemPower ? true,
# WARNING: NOT ALL COMBINATIONS OF THESE FLAGS YIELDS A BOOTABLE SYSTEM.
# even the combinations you'd expect to work, often don't.
  withMegiPinephoneConfig ? false,  #< if true, then start with megi's pinephone_defconfig
  withNixpkgsConfig ? true,  #< if true, then apply default config options from <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/common-config.nix>
  withFullConfig ? true,  #< if true, then try to build every unspecified option
# something inside nixpkgs calls `override` on the kernel and passes in extra arguments
  ...
}@args:

with lib;

let
  # HOW TO UPDATE:
  # - see: <https://xnux.eu/log/094.html>
  # - `git fetch torvalds`
  # - `curl -o .bundle https://xff.cz/kernels/git/orange-pi-active.bundle`
  # - `git fetch .bundle '+refs/heads/*:refs/remotes/megi/*'`
  #   - OR: `git bundle unbundle .bundle`
  # - there should be some new tag, like `refs/tags/orange-pi-6.4-20230907-1427`
  # checkout the revision associated with the tag, then:
  # - manually retag it, because `git bundle` doesn't actually import the tag
  #   - `git checkout <commit> ; git tag <tagname>`
  # - `git push origin <tag>`
  # - grab VERSION/PATCHLEVEL/SUBLEVEL/EXTRAVERSION from Makefile.
  #   - `rg '^(VERSION|PATCHLEVEL|SUBLEVEL|EXTRAVERSION) =' Makefile`
  #
  # update the commits/patches in here with:
  # - bash ~/ref/repos/armbian/build/tools/mk_format_patch ~/ref/repos/kernel.org/linux v6.11..HEAD ~/nixos/pkgs/additional/linux-megous/commits numbered=true
  #   the weird `PREF` prefix is apparently unavoidable
  #
  # for extra safety, pin to the same version as postmarketOS, in pmaports:
  # - device/main/linux-postmarketos-allwinner/APKBUILD
  # if `withModemPower = false` then update the commit for the "drop-modem-power" patch from pmOS, below
  #
  # build via: `nix build '.#hostConfigs.moby.boot.kernelPackages.kernel'`
  #
  # - megi publishes release notes as the most recent commit on any release tag, so just `git show` or `git log`
  # - orange-pi is listed as the "main integration branch".
  #   - this suggests it's NOT a stable branch, only `orange-pi-X.YY-YYYYMMDD-NNNN` tags are "formal" releases
  #   - specific branches like `pp` (pinephone) are dev branches, and probably less stable.
  rev = "orange-pi-6.11-20240915-2344";
  base = "6.11.0";
  hash = "sha256-rKxzSeq2w+l6pUPVu9z8XNj/28BmReOIPK55ScJDJdw=";
  # set to empty if not a release candidate, else `-rc<N>`
  rc = "";

  major = lib.versions.major base;
  minor = lib.versions.minor base;

  patches = import ./patches.nix { inherit lib newScope; };

  # pinephone uses the linux dtb at arch/arm64/boot/dts/allwinner/sun50i-a64-pinephone.dtsi
  # - this includes sun50i-a64.dtsi
  # - and sun50i-a64-cpu-opp.dtsi
  # - no need to touch the allwinner-h6 stuff: that's the SBC pine product
  # - i think it's safe to ignore sun9i stuff, but i don't know what it is
  kernelConfig = with lib.kernel; {
    # NB: nix adds the CONFIG_ prefix to each of these.
    # if you add the prefix yourself nix will IGNORE YOUR CONFIG.

    MODEM_POWER = lib.mkIf (!withModemPower) no;
    # normally a module; try inline? for vibration/haptics
    # INPUT_GPIO_VIBRA = yes;
    # INPUT_PWM_VIBRA = yes;
    # PWM_SUN4I = yes;

    # DRM_SUN4I = yes;  # DRM_SUN* defaults to module.
    # DRM_SUN8I_MIXER = yes;
    # DRM_SUN6I_DSI = yes;

    # taken from upstream linux pinephone_defconfig
    RTL8723CS = module;
    # BT_HCIUART_3WIRE = yes;
    # BT_HCIUART_RTL = yes;
    # RTL8XXXU_UNTESTED = yes;
    # BT_BNEP_MC_FILTER = yes;
    # BT_BNEP_PROTO_FILTER = yes;
    # BT_HS = yes;
    # BT_LE = yes;

    ### RUNTIME FIXES AFTER <https://github.com/NixOS/nixpkgs/pull/298332>
    # pmOS kernel config is in pmaports repo:
    # - CONFIG_FB_SIMPLE=y
    # - CONFIG_DRM_SIMPLEDRM is unset
    # - CONFIG_SYSFB_SIMPLEFB is not referenced
    # these config values are speculative: could probably be made smaller
    FB_SIMPLE = lib.mkForce yes;
    DRM_SIMPLEDRM = lib.mkForce no;  #< conflicts with FB_SIMPLE
    # SYSFB_SIMPLEFB = lib.mkForce no;
    # downgrade these from "yes" to "module", to match previous config.
    DRM = lib.mkForce module;
    # RC_CORE = lib.mkForce module;  # (IR) Remote Controllers
    # DRM_KMS_HELPER = lib.mkForce module;
    # AGP = lib.mkForce no;  # "Accelerated Graphics Port" (idk)

    # borrowed from megi (arch/arm64/configs/pinephone_defconfig), speculatively
    # ARM64_VA_BITS_39 = yes;  # nix sets ARM64_VA_BITS_52, which i expect overrides this.
    # SERIAL_8250_RUNTIME_UARTS = freeform "8";
    # MFD_SUN6I_PRCM = yes;
    # USB_LED_TRIG = yes;
    # USB_ANNOUNCE_NEW_DEVICES = yes;
    # MUSB_PIO_ONLY = yes;
    # DMABUF_HEAPS_SYSTEM = yes;

    # borrowed from postmarketOS, "to enable libcamera development"
    # - <https://gitlab.com/postmarketOS/pmaports/-/merge_requests/5084/diffs>
    DMABUF_HEAPS = yes;
    DMABUF_HEAPS_CMA = yes;
    # borrowed from postmarketOS, speculatively, as i debug megapixels camera
    # CMA_AREAS = "CMA allows to create CMA areas for particular purpose, mainly, used as device private area."
    #             "If unsure, leave the default value "8" in UMA and "20" in NUMA."
    # - pinephone in mainline linux, postmarketOS, defaults to 7
    # - nixos defaults to ... 19?
    CMA_AREAS = freeform "7";
    # DRM_ACCEL = lib.mkForce no;

    # USB_CONFIGFS_F_TCM = yes;
    # LEDS_BRIGHTNESS_HW_CHANGED = yes;  #< TODO: module?
    # VIDEO_SUNXI = yes; #< TODO: module?
    # # CONFIG_VIDEO_SUNXI_CEDRUS=y  #< implied by VIDEO_SUNXI (but as a module)
    # SUN50I_IOMMU = yes;
    # VALIDATE_FS_PARSER = yes;
    # consider: `DMA_SUN6I = yes;` (instead of the default, module)
    # try to fix "systemd[1]: bpf-lsm: Failed to load BPF object: No such process".
    # see: <https://github.com/anthraxx/linux-hardened/issues/93#issuecomment-1996742297>
    # somehow setting SECURITY_SELINUX, SECURITY_SEXLINUX_BOOTPARAM, LSM doesn't seem to actually fix this.
    # i wonder if i need `BPF_JIT_ALWAYS_ON=y`? or if systemd's bpf-lsm doesn't cross compile / doesn't support aarch64
    # SECURITY_SELINUX = yes;
    # SECURITY_SELINUX_BOOTPARAM = yes;
    # LSM = freeform "landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
  };

  ### options not necessary for a bootable system
  qualityOfLife = with lib.kernel; {
    # optimize for faster builds.
    # see <repo:kernel.org/linux:Documentation/admin-guide/quickly-build-trimmed-linux.rst>
    # note that several options can re-enable DEBUG_KERNEL (such as DEBUG_LIST)
    # DEBUG_KERNEL = lib.mkForce no;  # option group which seems to just gate the other DEBUG_ opts?
    DEBUG_INFO = lib.mkForce no;  # for gdb debugging (does it impact kernel stacktraces, too?)
    # DEBUG_INFO_NONE = lib.mkForce no;
    DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = lib.mkForce no;
    # DEBUG_LIST = lib.mkForce no;
    # DEBUG_MISC = lib.mkForce no;
    # DEBUG_FS = no;

    DEBUG_INFO_BTF = lib.mkForce no;  # BPF debug symbols. rec by <https://nixos.wiki/wiki/Linux_kernel#Too_high_ram_usage>
    # SCHED_DEBUG = lib.mkForce no;  # determines /sys/kernel/debug/sched
    # SUNRPC_DEBUG = lib.mkForce no;  # i use NFS though
    # shave 500ms off boot time (dmesg | grep raid6)
    # - by default raid6 (on behalf of btrfs) will compute the fastest algorithms at boot.
    # - AFAICT, this only comes into effect if using raid (i don't).
    # - in any case, on moby, the fastest benchmark happens to be the default anyway.
    # - on lappy/servo/desko, the default is about 3% slower than the fastest. but they compute this in < 100ms.
    RAID6_PQ_BENCHMARK = no;
  };

  ### OPTIONS ONLY NEEDED IF `withFullConfig` (i.e. `autoModules`) IS TRUE:
  fullConfigFixes = with lib.kernel; {
    ### BUILD FIXES, NOT SPECIFIC TO MY PREFERENCES
    #
    # disabling the sun5i_eink driver avoids this compilation error:
    # CC [M]  drivers/video/fbdev/sun5i-eink-neon.o
    # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfloat-abi=softfp'
    # aarch64-unknown-linux-gnu-gcc: error: unrecognized command line option '-mfpu=neon'
    # make[3]: *** [../scripts/Makefile.build:289: drivers/video/fbdev/sun5i-eink-neon.o] Error 1
    FB_SUN5I_EINK = no;
    BES2600 = no;  # fails to compile (implicit declaration of function 'ieee80211_tx_status'; did you mean 'ieee80211_tx_status_ni')
  };

  megiFixes = with lib.kernel; {
    # pinephone_defconfig specifies CONFIG_LSM, but without landlock. fix that:
    LSM = freeform "landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
  };

  # options needed if `withNixpkgsConfig` is enabled... even if `withFullConfig` is as well
  nixpkgsFixes = with lib.kernel; {
    SUN8I_DE2_CCU = lib.mkForce yes;  #< nixpkgs' option parser gets confused on this one, somehow
    #v XXX: required for e.g. SECURITY_LANDLOCK (specified by upstream nixpkgs) to take effect if `autoModules = false`
    #v seems that upstream linux (the defconfigs?), it defaults to Yes for:
    # - arch/x86/configs/x86_64_defconfig
    # - arch/arm64/configs/defconfig
    # but that it's left unset for e.g. arch/arm64/configs/pinephone_defconfig. TODO: upstream to nixpkgs
    SECURITY = yes;
    # SECURITY_SELINUX = yes;  #< not sure if actually required; it would usually be enabled by autoModules
    # SECURITY_SELINUX_BOOTPARAM = yes;
    # PCI needed because of the dependency on module `ahci`
    # like SECURITY, it's present for the default x86, arm64 defconfigs, but not the flavored ones.
    # PCI = yes;
  };

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
  # CONFIG_DRM_LIMA=m
  # CONFIG_DRM_BRIDGE=y
  # CONFIG_DRM_PANEL_BRIDGE=y
  # CONFIG_DRM_PANFROST=m
  # CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
  # CONFIG_DRM_PANEL_SIMPLE=m
  # CONFIG_DRM_PANEL_SITRONIX_ST7703=m
  # CONFIG_DRM_SUN4I=m
  # CONFIG_DRM_SUN6I_DSI=m
  # CONFIG_DRM_SUN8I_DW_HDMI=m
  # CONFIG_DRM_SUN8I_MIXER=m
  # CONFIG_DRM_SUN8I_TCON_TOP=m
  # CONFIG_FB_CORE=y
  # CONFIG_FB_DEVICE=y
  # CONFIG_FB_NOTIFY=y
  # CONFIG_FB_MODE_HELPERS=y
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

  # `pkgs.kernelPatches` is a set of common patches
  # while `kernelPatches` callarg is a list.
  # weird idiom, means we have to access pkgs.kernelPatches to access the actual patch directory:
  extraKernelPatches =
    # pkgs."linux_${major}_${minor}".kernelPatches ++
    [
      {
        name = "pinephone-enable-af8133j-magnetometer";
        patch = ./pinephone-1_2b-af8133j.patch;
      }
    # (patchDefconfig kernelConfig)
    # wake on wireless lan (WOWLAN) patches:
    # see: <https://gist.github.com/Peetz0r/bf8fd93a60962b4afcf2daeb4305da40>
    # see: <https://xnux.eu/log/031.html>
    # see: <https://irclog.whitequark.org/linux-sunxi/2021-02-19>
    # most of the relevant bits here (e.g. CONFIG_WOWLAN=y) have been merged
    # {
    #   # the pinephone device tree to `keep-power-in-suspend` for the WiFi peripherals
    #   # unclear if this is truly needed: a *different* piece of the device tree was set for keep-power-in-suspend
    #   # when megi merged Peetz0r's patch.
    #   # there appears to be support for WOWLAN even with this patch dropped.
    #   name = "pinephone-dt-keep-power-in-suspend";
    #   patch = fetchpatch {
    #     url = "https://git.uninsane.org/colin/linux/commit/afd6514fd3098047000b3f1f198c2256478dce46.patch";
    #     hash = "sha256-8OtGXpCPJbk3c3Z4DcurS0F+Ogqx+xahEv+256+4dcY=";
    #   };
    # }
    # {
    #   # experimental: set CONFIG_LPS_MODE = 0
    #   # uncertain what this does, LPS = "Leisure Power Savings"
    #   name = "disable-rtl8723cs-lps";
    #   patch = fetchpatch {
    #     url = "https://git.uninsane.org/colin/linux/commit/8bee908739b3b3aa505b22e558397d2d59060951.patch";
    #     hash = "sha256-DnLDseL1Ar5gE31CQUTrGNxxNu88jGCzj8ko99Z8vUA=";
    #   };
    # }
    # {
    #   # experimental: set CONFIG_ARP_KEEP_ALIVE and CONFIG_GTK_OL if CONFIG_WOWLAN=y
    #   # this patch just uncomments some commented-out #defines.
    #   # they were commented out from the first time megi imported this driver, never touched.
    #   # this may be problematic, occasionally requiring a driver re-probe. see other notes on wowlan/8723cs.
    #   # if continued errors, try removing the CONFIG_GTK_OL and keeping just CONFIG_ARP_KEEP_ALIVE.
    #   # seems to infrequently disrupt waking on ARP packets, as well.
    #   name = "enable-wowlan-offloads";
    #   patch = fetchpatch {
    #     url = "https://git.uninsane.org/colin/linux/commit/c4d2d12e31ae70bb43c6190eccc49e42ad645090.patch";
    #     hash = "sha256-B1rxeVu6y5hP/iMLSbl3ExwrEIXL7WShWsMFh6ko6yk=";
    #   };
    # }
    {
      name = "pinephone: wowlan: disable unicast";
      patch = fetchpatch {
        url = "https://git.uninsane.org/colin/linux/commit/3b3328cfb35b6cea3480c6358faf4d4175146372.patch";
        hash = "sha256-aBa63UHaU+KSWNzeXEamcMhJr2bRkJGZPTM7nBNu9wk=";
      };
    }
    # {
    #   name = "pinephone: wowlan: disable unicast/deauth/magic packet/arp";
    #   patch = fetchpatch {
    #     url = "https://git.uninsane.org/colin/linux/commit/624315afd2ebd44fc6d0056c206b502e50d92775.patch";
    #     hash = "sha256-KlgIJigK7G89obT7qWGdHqQ+eavYrCkuwo2d0wdUrpE=";
    #   };
    # }
    {
      # enables /proc/net/rtl8723cs/wlan0/gpio_info and gpio_set_direction, gpio_set_output_value.
      # `cat gpio_info` -> `get_gpio 0:0`
      # writing to gpio_set_output_value does change the value of gpio_info, but not of
      # /sys/kernel/debug/gpio
      name = "pinephone: rtl8723cs: enable CONFIG_GPIO_API";
      patch = fetchpatch {
        url = "https://git.uninsane.org/colin/linux/commit/51dea574a4559bd30fda2b0f852e42cad6cb6757.patch";
        hash = "sha256-pAmif5vMdZzgmyzkLmvdOltoXdeXeBeOhvGbpHWzIkc=";
      };
    }
    # {
    #   # this changes the IRQ definition in the devicetree, and at runtime the decompiled
    #   # fdt shows this change, but /proc/interrupts still shows as an edge interrupt.
    #   # no IRQs or GPIOs were changed at all, actually.
    #   # likely something else is configuring the IRQ at runtime.
    #   name = "pinephone: rtl8723cs: IRQ on LEVEL_LOW instead of EDGE_FALLING";
    #   patch = fetchpatch {
    #     url = "https://git.uninsane.org/colin/linux/commit/223046eac02c5b1ca6203f68df495d35ce191280.patch";
    #     hash = "sha256-Quhvz7hiM3TbpZ2pKuHVXrO8OLn3r7WNYYIjQc1CWcQ=";
    #   };
    # }
  ] ++ lib.optionals (!withModemPower) [
    {
      # Drop modem-power from DT to allow eg25-manager to have full control.
      # source: <https://github.com/NixOS/mobile-nixos/pull/573>
      name = "remove-modem-power-from-devicetree";
      patch = fetchpatch {
        url = "https://gitlab.com/postmarketOS/pmaports/-/raw/05a3c22d81591dd6b4b41a0ffebe1159be49b09b/device/main/linux-postmarketos-allwinner/0006-dts-pinephone-drop-modem-power-node.patch";
        hash = "sha256-dyxlzp73hQ2AsaQbLIl0B7bR7Z1PHIMUS+CFN0kkMTs=";
      };
    }
  ];


  # create a kernelPatch which overrides nixos' defconfig with extra options
  # patchDefconfig = config: {
  #   # defconfig options. this method comes from here:
  #   # - https://discourse.nixos.org/t/the-correct-way-to-override-the-latest-kernel-config/533/9
  #   name = "linux-megous-defconfig";
  #   patch = null;
  #   structuredExtraConfig = config;
  # };

in ((buildLinux {
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
}).override (args // {
  kernelPatches = (args.kernelPatches or []) ++ extraKernelPatches;

  defconfig = if withMegiPinephoneConfig then "pinephone_defconfig" else "defconfig";

  structuredExtraConfig =
    lib.optionalAttrs withMegiPinephoneConfig megiFixes
    // lib.optionalAttrs withNixpkgsConfig nixpkgsFixes
    // lib.optionalAttrs withFullConfig fullConfigFixes
    // qualityOfLife
    // (args.structuredExtraConfig or {})
    // kernelConfig;
  #v build a minimal kernel, without the options from <repo:nixos/nixpkgs:pkgs/os-specific/linux/kernel/common-config.nix>?
  #v but this will lack features like e.g. landlock, which my userspace depends on
  enableCommonConfig = withNixpkgsConfig;

  autoModules = withFullConfig;
  # for every module which was autoselected, if it supports being compiled into the kernel (i.e. has a `y` option), then do that instead of building it as a module.
  #   so, this option has no effect when `autoModules` is false.
  # the benefit i think is mostly that such modules get automatically included in the initrd?
  preferBuiltin = withFullConfig;
}))
.overrideAttrs (base: {
  passthru = (base.passthru or {}) // {
    inherit patches;
  };
})
