{
  fetchFromGitLab,
  lib,
  linuxManualConfig,
  sane-kernel-tools,
  writeTextFile,
  #VVV nixpkgs calls `.override` on the kernel to configure additional things, but we don't care about those things
  features ? null,
  kernelPatches ? null,
  randstructSeed ? "",
}:

let
  # VVV sources
  # - pmaports.rev: update this first.
  # - src.rev, version: grab from pmaports device/community/linux-pine64-pinephonepro/APKBUILD
  pmaports = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "pmaports";
    rev = "3c55399f10808efec83a265d3d11fcd30eeff070";  #< 2024-08-30: device/*: enable new options for community kconfig check (MR 5544)
    hash = "sha256-fbTyDjxBe4K3UMc5ofIriuMdRQyyHcEwMHE9aEAOzQM=";
  };
  src = fetchFromGitLab {
    owner = "pine64-org";
    repo = "linux";
    rev = "ppp-6.6-20231104-22589";
    hash = "sha256-wz2g+wE1DmhQQoldeiWEju3PaxSTIcqLSwamjzry+nc=";
  };
  version = "6.6.0";
  modDirVersion = "6.6.0";  # or X.Y.Z-rcN
  # ^^^ sources

  defconfigRaw = builtins.readFile "${pmaports}/device/community/linux-pine64-pinephonepro/config-pine64-pinephonepro.aarch64";
  defconfigStr =
    # fix build:
    # make[3]: *** [../scripts/Makefile.build:243: crypto/aegis128-neon-inner.o] Error 1
    #   /build/ccUPpJiV.s:596: Error: selected processor does not support aese v2.16b,v11.16b
    (lib.replaceStrings [ "CONFIG_CRYPTO_AEGIS128_SIMD=y" ] [ "CONFIG_CRYPTO_AEGIS128_SIMD=n" ] defconfigRaw)
    # add options i used in linux-postmarketos-allwinner to get nixos-flavored linux working as expected:
    + ''
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
  '';

in (linuxManualConfig {
  inherit src version modDirVersion randstructSeed;
  # inherit (linux-megous) extraMakeFlags modDirVersion src version;
  # inherit (linux-megous) kernelPatches;

  configfile = writeTextFile {
    name = "config-pine64-pinephonepro.aarch64";
    text = defconfigStr;
  };
  # nixpkgs requires to know the config as an attrset, to do various eval-time assertions.
  # that config is sourced from the pmaports repo, hence this is import-from-derivation.
  # if that causes issues, then copy the config inline to this repo.
  config = sane-kernel-tools.parseDefconfig defconfigStr;
}).overrideAttrs (base: {
  passthru = (base.passthru or {}) // {
    inherit defconfigStr;
    structuredConfig = sane-kernel-tools.parseDefconfigStructuredNonempty defconfigStr;
  };
})

