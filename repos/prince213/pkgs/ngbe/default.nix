{
  lib,
  fetchzip,
  kernel,
  kernelAtLeast,
  kernelModuleMakeFlags,
  stdenv,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ngbe";
  version = "1.2.7";

  src = fetchzip {
    name = "source";
    url = "https://www.net-swift.com/uploads/20250716/%E7%BD%91%E8%BF%851G%E7%BD%91%E5%8D%A1Linux%20%E9%A9%B1%E5%8A%A8%E6%BA%90%E7%A0%81.zip";
    hash = "sha256-+QHoQFt7qIfQ5pPmzPDmk0hKf+yHB0LQunVz/ikTbU0=";
    nativeBuildInputs = [ unzip ];
  };

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src/ngbe-${finalAttrs.version}.zip
    runHook postUnpack
  '';

  sourceRoot = "ngbe-${finalAttrs.version}/src";

  patches =
    (lib.optionals (kernelAtLeast "6.15") [
      # https://github.com/torvalds/linux/commit/8fa7292fee5c5240402371ea89ab285ec856c916
      ./del_timer_sync.patch
    ])
    ++ (lib.optionals (kernelAtLeast "6.16") [
      # https://github.com/torvalds/linux/commit/41cb08555c4164996d67c78b3bf1c658075b75f1
      ./from_timer.patch
    ])
    ++ (lib.optionals (kernelAtLeast "6.17") [
      # https://github.com/torvalds/linux/commit/e78f70bad29c5ae1e1076698b690b15794e9b81e
      ./cyclecounter.patch
    ]);

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
