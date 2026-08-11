/*
nix-build -E 'with import <nixpkgs> { }; callPackage ./default.nix { }'

based on
https://github.com/xddxdd/nur-packages/tree/812de98e6b0080c85a4a94e289fa0425165b7c3b/pkgs/linux-xanmod-lantian

NOTE vmlinux file is in the $dev output
*/

{ stdenv
, lib
, fetchFromGitHub
, linuxManualConfig
, linuxKernel
, runCommand
, fetchurl

# ignored:
, features ? null
, kernelPatches ? []
, randstructSeed ? null
}:

let
  baseKernel = linuxKernel.packageAliases.linux_latest.kernel;

  configfile = stdenv.mkDerivation rec {
    # https://github.com/firecracker-microvm/firecracker/blob/main/resources/microvm-kernel-x86_64.config
    name = "linux-firecracker.config";
    src-rev = "9b03e30a92c48be7fc061a46571e99862eaa1fd8";
    src-sha = "AEbQtRD7cWWJIzynEorT35wrfZrHnbSJ8a0wkC8wliE=";
    src = fetchurl rec {
      sha256 = src-sha;
      url = "https://github.com/firecracker-microvm/firecracker/raw/${src-rev}/resources/microvm-kernel-x86_64.config";
    };
    # FIXME? replace variable $UNAME_RELEASE: CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
    phases = "buildPhase";
    buildPhase = ''
      cp -v ${src} $out
      chmod +w $out
      echo "patching kernel config ..."
      echo "${extraConfig}" | while read line
      do
        if [ -z "$line" ] || [ "''${line:0:1}" = "#" ]; then continue; fi
        key=CONFIG_$(echo "$line" | cut -d' ' -f1)
        val=$(echo "$line" | cut -d' ' -f2)
        valEscaped=$(echo "$val" | sed 's|/|\\/|g')
        echo "debug: extraConfig: '$key' = '$val' (valEscaped: '$valEscaped')"
        sedOutput=$(sed -i -E "s/^(# )?$key( is not set|=.*)$/$key=$valEscaped/ w /dev/stdout" $out)
        if [ -z "$sedOutput" ]; then
          # not replaced. append new value
          echo "$key=$val" >>$out
        fi
      done
      echo "patching kernel config done. diff:"
      diff -u0 ${src} $out || true
    '';
  };

  # microvm.nix/nixos-modules/microvm.nix
  extraConfig = ''
    PVH y
    PARAVIRT y
    PARAVIRT_TIME_ACCOUNTING y
    HAVE_VIRT_CPU_ACCOUNTING_GEN y
    VIRT_DRIVERS y
    VIRTIO_BLK y
    FUSE_FS y
    VIRTIO_FS y
    #FS_DAX y
    #FUSE_DAX y
    BLK_MQ_VIRTIO y
    VIRTIO_NET y
    VIRTIO_BALLOON y
    VIRTIO_CONSOLE y
    VIRTIO_MMIO y
    VIRTIO_MMIO_CMDLINE_DEVICES y
    VIRTIO_PCI y
    VIRTIO_PCI_LIB y
    VIRTIO_VSOCKETS m
    EXT4_FS y
    SQUASHFS y
    SQUASHFS_XZ y

    # for Firecracker SendCtrlAltDel
    SERIO_I8042 y
    KEYBOARD_ATKBD y
    # for Cloud-Hypervisor shutdown
    ACPI_BUTTON y
    EXPERT y
    ACPI_REDUCED_HARDWARE_ONLY y
  ''
  # expose /proc/config.gz (debug)
  + ''
    IKCONFIG y
  ''
  # fix: Failed assertions in nixpkgs/nixos/modules/system/boot/systemd.nix system.requiredKernelConfig
  + ''
    CRYPTO_USER_API_HASH y
    AUTOFS4_FS y
  ''
  ;
in

linuxManualConfig rec {
  version = "${baseKernel.version}-firecracker";
  inherit stdenv lib configfile;
  inherit (baseKernel) src kernelPatches modDirVersion;
  allowImportFromDerivation = true;
}
