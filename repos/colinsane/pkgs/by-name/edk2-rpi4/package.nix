# WHEN UPDATING:
# - check the tag in <repo:nixos/nixpkgs:pkgs/by-name/ed/edk2/package.nix>
#   e.g. edk2-stable202505
# - figure the date, via `cd edk2 && git show edk2-stable202505`
# - pin the other repos to the closest commit
# consider updating to the known-good commits from <https://github.com/pftf/RPi4>
{
  acpica-tools,
  buildArmTrustedFirmware,
  edk2,
  fetchFromGitHub,
  lib,
}:
let
  armTrustedFirmwareRpi4 = buildArmTrustedFirmware rec {
    # see: <repo:tianocore/edk2-non-osi:Platform/RaspberryPi/RPi4/TrustedFirmware/Readme.md>
    # says they build it with:
    # > make PLAT=rpi4 RPI3_PRELOADED_DTB_BASE=0x1F0000 PRELOADED_BL33_BASE=0x20000 SUPPORT_VFP=1 SMC_PCI_SUPPORT=1 DEBUG=0 all
    # see also <repo:ARM-software/arm-trusted-firmware:plat/rpi/rpi4/platform.mk>
    platform = "rpi4";
    extraMeta.platforms = [ "aarch64-linux" ];
    filesToInstall = [ "build/${platform}/release/bl31.bin" ];
    # platformCanUseHDCPBlob = true;
    extraMakeFlags = [
      # these are the flags which tianocore, pftf build with.
      # RPI3_PRELOADED_DTB_BASE: "Auxiliary build option needed when using `RPI3_DIRECT_LINUX_BOOT=1`. This option allows to specify the location of a DTB in memory."
      # "RPI3_PRELOADED_DTB_BASE=0x1F0000"
      # PRELOADED_BL33_BASE: "Used to specify the fixed address of a BL33 binary that has been preloaded by earlier boot stages (VPU). Useful for bundling BL31 and BL33 in the same `armstub` image (e.g. TF-A + EDK2)."
      # IOW: ATF and EDK2 need to agree on the value of PRELOADED_BL33_BASE!
      "PRELOADED_BL33_BASE=0x20000"
      # SUPPORT_VFP: "allow Vector Floating Point operations in EL3".
      # where EL3 is the part of TFA which stays resident in the CPU;
      # ATF lowers to EL2 before passing control to the next boot stage;
      # i'd guess this is an (optional) optimization of some sort?
      # "SUPPORT_VFP=1"
      # SMC_PCI_SUPPORT: ATF rpi4/platform.mk defaults this to 0 and says "SMCCC PCI support (should be enabled for ACPI builds)".
      # "SMC_PCI_SUPPORT=1"
    ];
  };
  edk2-platforms = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-platforms";
    name = "edk2-platforms";
    rev = "d6eb4de31701a50b26da061919565c3a3460db88";  # 2025-08-04
    hash = "sha256-mpvfQGqk+kJeJpgiKRveg3Xcsi+WZK79ERjM4U65NCM=";
  };
  # edk2-src = fetchFromGitHub {
  #   owner = "tianocore";
  #   repo = "edk2";
  #   name = "edk2";
  #   # fetchSubmodules = true;
  #   rev = "060bb0e5a75946729defa4824fa899cf4cc0528b";
  #   # hash = "sha256-gafZ+iyJ0IpGpe3ucPw/Ap/3ZrY3gCNSJEpAqgBAzRY=";
  # };
  # edk2-non-osi = fetchFromGitHub {
  #   owner = "tianocore";
  #   repo = "edk2-non-osi";
  #   name = "edk2-non-osi";
  #   rev = "0544808c623bb73252310b1e5ef887caaf08c34b"; # 2024-03-14
  #   hash = "sha256-09D1p7xHT6rLxgdw7flT3gEWNKqxOhM2Q643t0nw9ww=";
  #   # rev = "3415f616e08a0d9c7bd264cab674929a7b0f5e33";  # 2025-08-04
  # };
in edk2.mkDerivation "Platform/RaspberryPi/RPi4/RPi4.dsc" {
  pname = "edk2-rpi4";
  inherit (edk2) version;

  nativeBuildInputs = [
    acpica-tools
  ];

  srcs = [
    edk2.src
    edk2-platforms
  ];

  sourceRoot = edk2.src.name;

  postPatch = ''
    # patch out the raspberry pi logo from the boot process, so as to remove dependency
    # on separate edk2-non-osi repo (which i would otherwise have to keep in sync)...
    # to instead build WITH the raspberry logo, remove these patches and set
    # PACKAGES_PATH=$edk2:$edk2-platforms:$edk2-non-osi
    #
    # N.B.: can either comment out the `LogoDxe.inf` lines, to build with no logo,
    # or point them to a different in-tree Logo (e.g. AMD, Intel, or tianocore (i.e. MdeModulePkg)).
    substituteInPlace ../edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.fdf \
      --replace-fail \
        'INF Platform/RaspberryPi/Drivers/LogoDxe/LogoDxe.inf' \
        'INF MdeModulePkg/Logo/LogoDxe.inf'
    substituteInPlace ../edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc \
      --replace-fail \
        'Platform/RaspberryPi/Drivers/LogoDxe/LogoDxe.inf' \
        'MdeModulePkg/Logo/LogoDxe.inf'

    export PACKAGES_PATH=$(pwd):$(pwd)/../edk2-platforms
  '';

  installPhase = ''
    runHook preInstall
    install -Dm644 Build/RPi4/RELEASE*/FV/RPI_EFI.fd $out/RPI_EFI.fd
    runHook postInstall
  '';

  buildFlags = [
    "-DTFA_BUILD_ARTIFACTS=${armTrustedFirmwareRpi4}"  #< or, place bl31.bin at Platform/RaspberryPi/RPi4/TrustedFirmware
    # default boot order is:
    # 1. PXEv4
    # 2. PXEv6
    # 3. HTTPv4
    # 4. HTTPv6
    # 5. SD
    # i want SD first, and this is most easily achieved by simply disabling networking
    "-DNETWORK_ENABLE=FALSE"
    # TODO: try enabling this, to disable the 3GB RAM limit:
    # "--pcd" "gRaspberryPiTokenSpaceGuid.PcdRamLimitTo3GB=0"
    #
    # flags taken from <https://github.com/pftf/RPi4/blob/master/.github/workflows/linux_edk2.yml#L63>
    # in practice, none seem to be required
    # "-DSECURE_BOOT_ENABLE=TRUE"
    # "-DINCLUDE_TFTP_COMMAND=TRUE"
    # "-DNETWORK_ISCSI_ENABLE=TRUE"
    # "-DSMC_PCI_SUPPORT=1"
    # "-DNETWORK_TLS_ENABLE=FALSE"
    # "-DNETWORK_ALLOW_HTTP_CONNECTIONS=TRUE"
  ];

  # fixes `error: -Wformat-security ignored without -Wformat`
  env.NIX_CFLAGS_COMPILE = "-Wformat";

  passthru = {
    inherit
      # edk2-non-osi
      edk2-platforms
      # edk2-src
      armTrustedFirmwareRpi4
    ;
  };

  meta = {
    maintainers = with lib.maintainers; [
      colinsane
    ];
    platforms = [ "aarch64-linux" ];
  };
}
