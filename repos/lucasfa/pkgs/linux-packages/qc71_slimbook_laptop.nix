{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  nix-update-script,
}:

stdenv.mkDerivation rec {
  pname = "qc71_slimbook_laptop";
  version = "1.3.1-unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "Slimbook-Team";
    repo = "qc71_laptop";
    rev = "dfa11f6cc6093103d89ab029381a5fb6c886301e";
    hash = "sha256-9UCE/m8c4iCUAe1ftHXdg8uTwDowU82CWensSJ1o5yA=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "VERSION=${version}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$PWD modules_install INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=extra DEPMOD=true \
      ''${makeFlags[@]}
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=generic_slimbook" ];
  };

  meta = with lib; {
    description = "Linux driver for QC71 laptop, with Slimbook patches";
    homepage = "https://github.com/Slimbook-Team/qc71_laptop/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ lucasfa ];
    platforms = platforms.linux;
  };
}
