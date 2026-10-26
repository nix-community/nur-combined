{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  kernel,
  kernelModuleMakeFlags,
  kmod,
}:

let
  kernelDir = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cix-vpu-driver";
  # CIX publishes the P1 kernel 7.0 driver line as `p1_7.0_v<version>` tags.
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "cixtech";
    repo = "cix_opensource__vpu_driver";
    tag = "p1_7.0_v${finalAttrs.version}";
    hash = "sha256-BRwQmDkakclWaKXHqIDrSd7hqkAituiDoDWfEFVU6YU=";
  };

  # Upstream ships `driver/Kbuild` that already defines the module wiring
  # correctly (`-I$(src)`, `obj-$(CONFIG_VIDEO_LINLON) := amvx.o`, full
  # object list). The repo-root Makefile is a DKMS-style wrapper whose
  # EXTRA_CFLAGS depend on `$(PWD)` — which Kbuild reassigns under us —
  # plus it has CRLF endings that defeat simple substitution. So just
  # build directly from `driver/` using the in-tree Kbuild.
  sourceRoot = "${finalAttrs.src.name}/driver";

  nativeBuildInputs = [ kmod ] ++ kernel.moduleBuildDependencies;

  hardeningDisable = [
    "format"
    "pic"
  ];

  # The Kbuild gates the `amvx` module on `CONFIG_VIDEO_LINLON`. Nothing
  # else in the tree sets it, so promote it here just for our build.
  buildPhase = ''
    runHook preBuild
    make -C ${kernelDir} M=$PWD modules \
      ${lib.escapeShellArgs kernelModuleMakeFlags} \
      CONFIG_VIDEO_LINLON=m \
      KCFLAGS=-DCONFIG_VIDEO_LINLON=1
    runHook postBuild
  '';

  # Install through Kbuild's `modules_install` so the kernel's signing rule
  # (kmodigest on current nixpkgs) and module compression apply; NixOS's
  # module aggregation expects the resulting per-module `.ko.cer`. Also expose
  # the uapi header for userspace consumers (cix-vaapi, cix-ffmpeg).
  installPhase = ''
    runHook preInstall
    make -C ${kernelDir} M=$PWD modules_install \
      ${lib.escapeShellArgs kernelModuleMakeFlags} \
      INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=extra DEPMOD=true
    install -Dm644 linux/mvx-v4l2-controls.h \
      "$out/include/cix/mvx-v4l2-controls.h"
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "p1_7.0_v"; };

  meta = {
    description = "Out-of-tree V4L2 M2M driver for the CIX P1 (Sky1) VPU (amvx)";
    homepage = "https://github.com/cixtech/cix_opensource__vpu_driver";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = [ "aarch64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
