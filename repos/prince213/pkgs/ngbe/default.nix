{
  lib,
  fetchzip,
  kernel,
  kernelModuleMakeFlags,
  stdenv,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ngbe";
  version = "1.2.8";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchzip {
    name = "source";
    url = "https://www.net-swift.com/uploads/20260713/%E7%BD%91%E8%BF%851G%E7%BD%91%E5%8D%A1Linux%20%E9%A9%B1%E5%8A%A8%E6%BA%90%E7%A0%81.zip";
    hash = "sha256-8vMasyJfS8a6iyOvx8Cfd0omf2LV17sh9fUZEN/Z01U=";
    nativeBuildInputs = [ unzip ];
  };

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src/ngbe-${finalAttrs.version}.zip
    runHook postUnpack
  '';

  sourceRoot = "ngbe-${finalAttrs.version}/src";

  postPatch = ''
    substituteInPlace common.mk --replace-fail /sbin/depmod true
  '';

  makeFlags =
    let
      path = "${kernel.dev}/lib/modules/${kernel.modDirVersion}";
    in
    kernelModuleMakeFlags
    ++ [
      "KSRC=${path}/source"
      "KOBJ=${path}/build"
      "INSTALL_MOD_PATH=$(out)"
      "MANDIR=/share/man"
    ];

  meta = {
    description = "WangXun Gigabit Ethernet Driver";
    homepage = "https://www.net-swift.com/";
    downloadPage = "https://www.net-swift.com/c/down.html?filter[type]=1";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "2.6";
  };
})
