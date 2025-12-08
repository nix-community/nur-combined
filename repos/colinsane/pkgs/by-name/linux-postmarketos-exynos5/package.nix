{
  lib,
  linux ? linux_6_1, linux_6_1,
  linuxManualConfig,
  optimizeForSize ? false,
  useEdpPanel ? false,  #< use `edp-panel` driver in snow device tree (fails to fix graphics)
  revertPanelSimplePatch ? false,  #< revert the commit which removed B116XW03 panel from panel-edp driver (fixes display output)
  sane-kernel-tools,
  writeTextFile,
#v nixpkgs calls `.override` on the kernel to configure additional things
  features ? [],
  randstructSeed ? "",
  ...
}@args:

let
  defconfigPmos = builtins.readFile ./config-postmarketos-exynos5.arm7;

  patches = {
    useEdpPanel = {
      name = "snow: use edp-panel driver";
      patch = ./snow-panel-fix.patch;
    };
    revertPanelSimplePatch = {
      name = "revert ad3e33fe071dffea07279f96dab4f3773c430fe2, and get snow to use edp-panel again";
      patch = ./snow-panel-revert-b116xw03.patch;
    };
  };

  # remove CONFIG_LOCALVERSION else nixpkgs complains about mismatched modDirVersion
  withoutOsFlavor = defconfig: lib.replaceStrings
    [ ''CONFIG_LOCALVERSION="-postmarketos-exynos5"'' ]
    [ ''CONFIG_LOCALVERSION='' ]
    defconfig
  ;

  # XXX(2024/06/06): if this module is loaded before udev, then kernel panic.
  # see: <repo:NixOS/mobile-nixos:devices/families/mainline-chromeos/default.nix>
  withModuleFixes = defconfig: lib.replaceStrings
    [ ''CONFIG_BATTERY_SBS=y'' ]
    [ ''CONFIG_BATTERY_SBS=m'' ]
    defconfig
  ;

  withOptimizations = defconfig: if optimizeForSize then
    lib.replaceStrings
      [ ''CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y'' ]
      # XXX(2024/06/06): if the bzImage is too large, it fails to boot.
      # probably an issue with the uboot relocations; not sure exactly what the size limit is.
      # XXX(2024/06/08): it now boots fine with the stock optimizations, though the difference in size is only 500KiB (about 10%).
      # perhaps this was mis-diagnosed
      [ ''CONFIG_CC_OPTIMIZE_FOR_SIZE=y'' ]
      defconfig
  else
    defconfig
  ;

  withNixosRequirements = defconfig: defconfig + ''
    #
    # Extra nixpkgs-specific options
    # nixos/modules/system/boot/systemd.nix wants CONFIG_DMIID
    # nixos/modules/services/hardware/udev.nix wants CONFIG_MODULE_COMPRESS_ZSTD
    #
    CONFIG_DMIID=y
    CONFIG_MODULE_COMPRESS_ZSTD=y

    CONFIG_DRM_LIMA=y
    CONFIG_DRM_MALI_DISPLAY=m

    #
    # Extra sane-specific options
    #
    CONFIG_SECURITY=y
    CONFIG_SECURITY_LANDLOCK=y
    CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
  '';

  defconfigStr = withNixosRequirements (
    withOptimizations (
      withModuleFixes (
        withoutOsFlavor (
          defconfigPmos
        )
      )
    )
  );
in (linuxManualConfig {
  inherit (linux) extraMakeFlags modDirVersion src version;
  inherit features randstructSeed;
  kernelPatches = (args.kernelPatches or []) ++ lib.optionals useEdpPanel [
    patches.useEdpPanel
  ] ++ lib.optionals revertPanelSimplePatch [
    patches.revertPanelSimplePatch
  ];

  configfile = writeTextFile {
    name = "config-postmarketos-exynos5.arm7";
    text = defconfigStr;
  };
  # nixpkgs requires to know the config as an attrset, to do various eval-time assertions.
  # this forces me to include the defconfig inline, instead of fetching it the way i do all the other pmOS kernel stuff.
  config = sane-kernel-tools.parseDefconfig defconfigStr;
}).overrideAttrs (base: {
  passthru = (base.passthru or {}) // {
    sanePatches = patches;
  };
})
