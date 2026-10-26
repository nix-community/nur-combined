{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpu-unlock";
  version = "1.1.1-unstable-2026-10-26";

  src = fetchFromGitHub {
    owner = "JustAResearcher";
    repo = "gpu-unlock-ada";
    rev = "d28c485418c3d9d034cd4bac19200bc33dd3453b";
    hash = "sha256-+asA7z8uR3dwJROyK8xl2Xe2VvWmVv/vZ8nx/SjB4fk=";
  };

  sourceRoot = "${finalAttrs.src.name}/kernel/gpu_unlock";

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  # Upstream's Makefile has no install target. Install through Kbuild's
  # `modules_install` so the kernel's signing rule (kmodigest on current
  # nixpkgs) and module compression apply; NixOS's module aggregation expects
  # the resulting per-module `.ko.cer`.
  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$PWD modules_install \
      ${lib.escapeShellArgs kernelModuleMakeFlags} \
      INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=extra DEPMOD=true
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Linux module enabling the SM speed-select override on RTX 4090 and selected Ada GPUs before the NVIDIA driver loads";
    homepage = "https://github.com/JustAResearcher/gpu-unlock-ada";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ codgician ];
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
