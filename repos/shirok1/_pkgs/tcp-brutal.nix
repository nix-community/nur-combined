{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:

stdenv.mkDerivation rec {
  pname = "tcp-brutal";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "apernet";
    repo = "tcp-brutal";
    rev = "v${version}";
    hash = "sha256-rx8JgQtelssslJhFAEKq73LsiHGPoML9Gxvw0lsLacI=";
  };

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNEL_RELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  installPhase = ''
    runHook preInstall

    make -C "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build" \
        M="$PWD" \
        INSTALL_MOD_PATH="$out" \
        INSTALL_MOD_DIR="extra" \
        modules_install

    runHook postInstall
  '';

  meta = {
    description = "TCP Brutal is Hysteria's congestion control algorithm ported to TCP, as a Linux kernel module.";
    homepage = "https://github.com/apernet/tcp-brutal";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
