{
  fetchFromGitHub,
  lib,
  llvmPackages,
  nix-update-script,
}:
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "dtbloader";
  version = "1.5.5";
  src = fetchFromGitHub {
    owner = "TravMurav";
    repo = "dtbloader";
    tag = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-KxeFtzi9iWlnvAdHyM7NF/RX0n+dGyHM7ZrJkqer3F0=";
  };
  nativeBuildInputs = with llvmPackages; [
    clang-unwrapped
    lld
    llvm
  ];

  hardeningDisable = [ "all" ];

  makeFlags = [
    "CC=${llvmPackages.clang-unwrapped}/bin/clang"
    "LD=${llvmPackages.lld}/bin/lld-link"
    "AR=${llvmPackages.llvm}/bin/llvm-ar"
  ];

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 build-aarch64/dtbloader.efi $out/dtbloader.efi

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/TravMurav/dtbloader/releases/tag/${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "EFI driver that finds and installs DeviceTree into the UEFI configuration table";
    homepage = "https://github.com/TravMurav/dtbloader";
    license = lib.licenses.bsd2;
    platforms = [ "aarch64-linux" ];
  };
})
