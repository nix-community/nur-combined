{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  quilt,
}:

stdenv.mkDerivation rec {
  pname = "cix-vpu-driver";
  version = "1.1.0";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__vpu_driver";
    rev = "8010c94da3534398555bb53f48332981e1469149";
    hash = "sha256-RRZPRHJBzwqw6vDL4TrPEoTcnQhFkOoh4JsDo6ky3e4=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies ++ [ quilt ];

  patchPhase = ''
    runHook prePatch
    QUILT_PATCHES=debian/patches quilt push -a
    runHook postPatch
  '';

  buildPhase = ''
    runHook preBuild

    CONFIG_VIDEO_LINLON=m CONFIG_VIDEO_LINLON_MONO=y CONFIG_VIDEO_LINLON_IF_V4L2=y \
    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
        M="$PWD/driver" \
        -j$NIX_BUILD_CORES \
        modules

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
        M="$PWD/driver" \
        INSTALL_MOD_PATH="$out" \
        modules_install

    install -Dm644 firmware-binaries/*.fwb -t "$out/lib/firmware"
    install -Dm644 driver/linux/mvx-v4l2-controls.h -t "$dev/include/linux"

    runHook postInstall
  '';

  meta = {
    description = "CIX VPU driver, Linux kernel module.";
    homepage = "https://github.com/cixtech/cix_opensource__vpu_driver/tree/cix_mainline_dev";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
