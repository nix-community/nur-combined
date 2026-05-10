{
  stdenv,
  lib,
  kernel,
  nvidia_x11,
}:
stdenv.mkDerivation {
  pname = "nvidia-kernel-modules";
  version = "${nvidia_x11.version}-${kernel.version}";

  src = nvidia_x11.modsrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  postPatch = ''
    if [ -f "nvidia-vgpu-vfio/vgpu-vfio-mdev.c" ]; then
      substituteInPlace nvidia-vgpu-vfio/vgpu-vfio-mdev.c \
        --replace-warn "int nv_vfio_mdev_register_driver()" "int nv_vfio_mdev_register_driver(void)" \
        --replace-warn "void nv_vfio_mdev_unregister_driver()" "void nv_vfio_mdev_unregister_driver(void)"
    fi

    if [ -f "nvidia-vgpu-vfio/nvidia-vgpu-vfio.c" ]; then
      substituteInPlace nvidia-vgpu-vfio/nvidia-vgpu-vfio.c \
        --replace-warn "no_llseek," "NULL," \
        --replace-warn "defined(NV_ENABLE_APICV_PRESENT)" "0"
    fi

    if [ -f "nvidia-vgpu-vfio/vgpu-ctldev.c" ]; then
      substituteInPlace nvidia-vgpu-vfio/vgpu-ctldev.c \
        --replace-warn "void nv_free_vgpu_type_info()" "void nv_free_vgpu_type_info(void)"
    fi
  '';

  makeFlags =
    kernel.commonMakeFlags
    ++ [
      "IGNORE_PREEMPT_RT_PRESENCE=1"
      "SYSSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/source"
      "SYSOUT=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "MODLIB=$(out)/lib/modules/${kernel.modDirVersion}"
      "DATE="
      "TARGET_ARCH=${stdenv.hostPlatform.parsed.cpu.name}"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "C_INCLUDE_PATH=${lib.getLib stdenv.cc.cc}/lib/clang/${lib.versions.major stdenv.cc.cc.version}/include"
    ];

  buildTargets = [ "modules" ];
  installTargets = [ "modules_install" ];
  enableParallelBuilding = true;

  allowedReferences = [ ];

  meta = nvidia_x11.meta // {
    description = "${nvidia_x11.meta.description} - Kernel modules";
    outputsToInstall = [ "out" ];
  };
}
