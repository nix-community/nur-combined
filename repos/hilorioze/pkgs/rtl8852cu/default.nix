{ lib
, stdenv
, fetchFromGitHub
, bc
, kernel
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rtl8852cu";
  version = "${kernel.version}-unstable-2025-08-20";

  src = fetchFromGitHub {
    owner = "morrownr";
    repo = "rtl8852cu-20240510";
    rev = "15788c86a7ae14dd74cac7e475b6f4a9953a2c8c";
    hash = "sha256-nd6SoIG28Y29OXlwofrIqH8UNBVq9/TVsapX+ADuw10=";
  };

  nativeBuildInputs = [
    bc
  ] ++ kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" ];

  enableParallelBuilding = true;

  NIX_CFLAGS_COMPILE = [
    "-Wno-error=date-time"
  ];

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace-fail /sbin/depmod \# \
      --replace-fail '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/" \
      --replace-fail 'cp -f $(MODULE_NAME).conf /etc/modprobe.d' \
      'mkdir -p $out/etc/modprobe.d && cp -f $(MODULE_NAME).conf $out/etc/modprobe.d' \
      --replace-fail "sh edit-options.sh" ""
  '';

  makeFlags = [
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KVER=${kernel.modDirVersion}"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
    "USER_MODULE_NAME=8852cu"
  ] ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  buildFlags = [ "modules" ];

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  installPhase = ''
    runHook preInstall
    modDir="$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
    install -Dm644 8852cu.ko "$modDir/8852cu.ko"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux Driver for USB WiFi Adapters that are based on the RTL8832CU and RTL8852CU Chipsets - v1.19.2.1 - 20240510";
    homepage = "https://github.com/morrownr/rtl8852cu-20240510";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ ];
    broken = kernel.kernelOlder "5.10" || kernel.kernelAtLeast "6.17";
  };
})
