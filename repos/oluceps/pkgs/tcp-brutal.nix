{
  kernel,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "tcp-brutal";
  src = fetchFromGitHub {
    owner = "apernet";
    repo = finalAttrs.name;
    rev = "204aeea3437a83599c1c1fa1b97e4425cfdfc49d";
    hash = "sha256-rx8JgQtelssslJhFAEKq73LsiHGPoML9Gxvw0lsLacI=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags ++ [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];
  installPhase = ''
    install -D brutal.ko $out/lib/modules/${kernel.modDirVersion}/misc/brutal.ko
  '';
})
