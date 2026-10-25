{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  libyuv,
  ocl-icd,
  opencl-headers,
}:

# CIX Media Engine runtime used by the 2026Q2 VA-API driver's VPP path.
# Upstream's DPU backend depends on the unpublished `libdrm_cix`; disable
# that backend while retaining the CPU/libyuv and OpenCL implementations.
stdenv.mkDerivation {
  pname = "cix-media-engine";
  version = "1.1.0-unstable-2026-07-20";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_media_engine";
    rev = "d228a7639157dece59d5eda5c318d8e4b93eeee9";
    hash = "sha256-o4a9LrKTTin5HQXYzi+zfSksa7lxjTMLav7fTalhpaY=";
  };

  postUnpack = ''
    sourceRoot="$sourceRoot/libcme"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libyuv
    ocl-icd
    opencl-headers
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail ' -L$(PATH_SYSROOT)/usr/share/cix/lib -ldrm_cix' "" \
      --replace-fail 'LDFLAGS+= -Wl,-rpath,`pkg-config --cflags --libs OpenCL` -Wl,--enable-new-dtags' \
                     'LDFLAGS += -Wl,--enable-new-dtags' \
      --replace-fail '$(shell find $(SRC_DIR) -name "*.c")' \
                     '$(shell find $(SRC_DIR) -name "*.c" ! -path "$(SRC_DIR)/drm/*")' \
      --replace-fail 'pkg-config --cflags --libs OpenCL' \
                     '$(PKG_CONFIG) --cflags --libs OpenCL'

    substituteInPlace source/cme_task.c \
      --replace-fail $'\r' "" \
      --replace-fail '#include "cme_drm.h"' "" \
      --replace-fail $'                if (task->hwaccelMask & MAKE_MASK(CME_HWACCEL_DPU)) {\n                    ret = drm_process_task(-1, task);\n                } else if (task->hwaccelMask & MAKE_MASK(CME_HWACCEL_GPU)) {' \
                     $'                if (task->hwaccelMask & MAKE_MASK(CME_HWACCEL_GPU)) {'

    substituteInPlace source/cme_hwaccel.c \
      --replace-fail 'MAKE_MASK(CME_HWACCEL_CPU) | MAKE_MASK(CME_HWACCEL_DPU)' \
                     'MAKE_MASK(CME_HWACCEL_CPU)' \
      --replace-fail 'MAKE_MASK(CME_HWACCEL_DPU) | MAKE_MASK(CME_HWACCEL_CL)' \
                     'MAKE_MASK(CME_HWACCEL_CL)' \
      --replace-fail '.entry_mask =  MAKE_MASK(CME_HWACCEL_DPU),' \
                     '.entry_mask =  0,'

    substituteInPlace source/cixcl/cixcl_entry.c \
      --replace-fail '"/usr/share/cix/lib/cme"' '"'"$out"'/share/cix/lib/cme"'
  '';

  makeFlags = [
    "PATH_SYSROOT="
    "CC=${stdenv.cc.targetPrefix}g++"
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib" "$out/include/cme" "$out/share/cix/lib/cme"
    cp -a output/lib/. "$out/lib/"
    cp -a include/cme*.h "$out/include/cme/"
    cp -a source/cixcl/kernels/. "$out/share/cix/lib/cme/"
    runHook postInstall
  '';

  meta = {
    description = "CIX Media Engine runtime for accelerated image processing";
    homepage = "https://github.com/cixtech/cix_media_engine";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [ "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
}
