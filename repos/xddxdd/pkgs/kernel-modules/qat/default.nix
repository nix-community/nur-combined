{
  stdenv,
  sources,
  lib,
  kernel,
  pkg-config,
  udev,
  libnl,
  pciutils,
  nasm,
  zlib,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.qat) pname src;
  version = lib.removePrefix "QAT.L." (builtins.elemAt (lib.splitString "/" sources.qat.version) 1);

  sourceRoot = ".";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ pkg-config ];
  buildInputs = [
    udev
    libnl
    pciutils
    nasm
    zlib
  ];

  patches = [ ./fix-build-without-pcieaer.patch ];

  KERNEL_SOURCE_ROOT = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  configureFlags = [
    "--enable-kapi"
    "--enable-qat-lkcf"
    "--enable-legacy-algorithms"
  ];

  inherit (kernel) makeFlags;

  postInstall = ''
    find $out/lib/modules/${kernel.modDirVersion}/updates/drivers/crypto/qat/ -name \*.ko.\* -exec mv {} $out/lib/modules/${kernel.modDirVersion}/updates \;
    rm -rf $out/lib/modules/${kernel.modDirVersion}/updates/drivers
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Intel® QuickAssist Technology (Intel® QAT) provides cryptographic and compression acceleration capabilities used to improve performance and efficiency across the data center.";
    homepage = "https://www.intel.com/content/www/us/en/download/19734/intel-quickassist-technology-driver-for-linux-hw-version-1-x.html";
    license = with lib.licenses; [
      gpl2Only
      bsd3
      asl20
    ];
    platforms = lib.platforms.linux;
  };
}
