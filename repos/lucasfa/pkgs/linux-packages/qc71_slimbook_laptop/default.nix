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
  version = "0-unstable-2024-12-18";

  src = fetchFromGitHub {
    owner = "Slimbook-Team";
    repo = "qc71_laptop";
    rev = "d7c37e911f232ddce28f45ef57dd03cbe7faf621";
    hash = "sha256-0agigos7Z9uljBki/dzV2XjjNyAj95tYMA0YlqAcD48=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "VERSION=${version}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    install -D qc71_laptop.ko -t $out/lib/modules/${kernel.modDirVersion}/extra
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=slimbook" ];
  };

  meta = with lib; {
    broken = true;
    description = "Linux driver for QC71 laptop, with Slimbook patches";
    homepage = "https://github.com/Slimbook-Team/qc71_laptop/";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ lucasfa ];
    platforms = platforms.linux;
  };
}
