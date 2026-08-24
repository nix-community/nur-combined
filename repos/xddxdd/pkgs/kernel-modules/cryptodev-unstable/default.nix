{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,
  kernel ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cryptodev-linux";
  version = "cryptodev-linux-1.14-unstable-2025-11-03";
  src = fetchFromGitHub {
    owner = "cryptodev-linux";
    repo = "cryptodev-linux";
    rev = "08644db02d43478f802755903212f5ee506af73b";
    hash = "sha256-tYTiyysofO23ApXQbnJF5muTTLv1kKu/nLggGv3ntr4=";
  };
  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  makeFlags = (kernel.commonMakeFlags or kernel.makeFlags) ++ [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
    "prefix=$(out)"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Device that allows access to Linux kernel cryptographic drivers";
    homepage = "http://cryptodev-linux.org/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
