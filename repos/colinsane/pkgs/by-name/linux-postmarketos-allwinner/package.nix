{
  lib,
  fetchurl,
  fetchFromGitea,
  fetchFromGitLab,
  linux-megous,
  linuxManualConfig,
  sane-kernel-tools,
  writeTextFile,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things, but we don't care about those things
  features ? null,
  kernelPatches ? null,
  randstructSeed ? "",
  withModemPower ? false,
  withPmosPatches ? true,
}:

# to update:
# - bump the `pmaportsRef` commit
# - null the hash in pmPatch
# - `wget https://gitlab.com/postmarketOS/pmaports/-/raw/$pmaportsRef/device/main/linux-postmarketos-allwinner/config-postmarketos-allwinner.aarch64`
# - update src/version/modDirVersion further down (take from pmaports APKBUILD)
let
  # VVV sources
  # - pmaports.rev: update this first.
  # - src.rev, version: grab from pmaports device/main/linux-postmarketos-allwinner/APKBUILD
  pmaports = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "3c55399f10808efec83a265d3d11fcd30eeff070";  #< 2024-08-30: device/*: enable new options for community kconfig check (MR 5544)
    hash = "sha256-fbTyDjxBe4K3UMc5ofIriuMdRQyyHcEwMHE9aEAOzQM=";
  };
  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "megi";
    repo = "linux";
    rev = "orange-pi-6.9-20240721-2345";
    hash = "sha256-WtLkMJnThYMLsZqbqTIhaTwQ0e2EE1Zq7DQX36L481o=";
  };
  version = "6.9.10";
  modDirVersion = "6.9.10";  # or X.Y.Z-rcN
  # ^^^ sources

  pmPatch = name: {
    inherit name;
    patch = "${pmaports}/device/main/linux-postmarketos-allwinner/${name}.patch";
  };

  # defconfigStr = (builtins.readFile ./config-postmarketos-allwinner.aarch64) + ''
  defconfigStr = (builtins.readFile "${pmaports}/device/main/linux-postmarketos-allwinner/config-postmarketos-allwinner.aarch64") + ''
    #
    # Extra nixpkgs-specific options
    # nixos/modules/system/boot/systemd.nix wants CONFIG_DMIID
    # nixos/modules/services/networking/firewall-iptables.nix wants CONFIG_IP_NF_MATCH_RPFILTER
    #
    CONFIG_DMIID=y
    CONFIG_IP_NF_MATCH_RPFILTER=y

    #
    # Extra sane-specific options
    #
    CONFIG_SECURITY_LANDLOCK=y
    CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,selinux,smack,tomoyo,apparmor,bpf";
  '' + lib.optionalString withModemPower ''
    CONFIG_MODEM_POWER=y
  '';

in (linuxManualConfig {
  inherit src version modDirVersion randstructSeed;
  # inherit (linux-megous) extraMakeFlags modDirVersion src version;
  # inherit (linux-megous) kernelPatches;

  configfile = writeTextFile {
    name = "config-postmarketos-allwinner.aarch64";
    text = defconfigStr;
  };
  # nixpkgs requires to know the config as an attrset, to do various eval-time assertions.
  # that config is sourced from the pmaports repo, hence this is import-from-derivation.
  # if that causes issues, then copy the config inline to this repo.
  config = sane-kernel-tools.parseDefconfig defconfigStr;

  # these likely aren't *all* required for pinephone: pmOS kernel is shared by many devices
  kernelPatches = lib.optionals withPmosPatches [
    (pmPatch "0001-dts-add-dontbeevil-pinephone-devkit")
    (pmPatch "0002-dts-add-pinetab-dev-old-display-panel")
    (pmPatch "0003-dts-pinetab-add-missing-ohci1")
    (pmPatch "0004-dts-pinetab-make-audio-routing-consistent-with-pinep")
  ] ++ lib.optionals (withPmosPatches && !withModemPower) [
    (pmPatch "0005-dts-pinephone-drop-modem-power-node")
  ] ++ lib.optionals withPmosPatches [
    (pmPatch "0006-drm-panel-simple-Add-Hannstar-TQTM070CB501")
    (pmPatch "0007-ARM-dts-sun6i-Add-GoClever-Orion-70L-tablet")
    (pmPatch "0008-drm-panel-simple-Add-Hannstar-HSD070IDW1-A")
    (pmPatch "0009-ARM-dts-sun6i-Add-Lark-FreeMe-70.2S-tablet")
    (pmPatch "0010-eMMC-workaround")
    (pmPatch "0011-arm64-dts-allwinner-orangepi-3-fix-ethernet")
    (pmPatch "0012-ARM-dts-allwinner-sun5i-a13-pocketbook-614-plus-Add-")
  ] ++ [
    {
      name = "pinephone-1.2b-add-af8133j-magnetometer";
      patch = linux-megous.patches.af8133j;
    }
  ];
}).overrideAttrs (base: {
  passthru = (base.passthru or {}) // {
    inherit defconfigStr;
  };
})
