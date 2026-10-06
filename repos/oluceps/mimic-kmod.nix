{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kmod,
}:

stdenv.mkDerivation {
  pname = "mimic-kmod";
  version = "unstable-2024-03-22";

  src = fetchFromGitHub {
    owner = "hack3ric";
    repo = "mimic";
    rev = "b1f0701b90b7a070e3aa2bd701ee409f79353824";
    sha256 = "19y11akj67n3x0gna08wrrip4kv110m5jzp5mbicwsb6ay0vaw72";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    runHook preBuild
    make -C kmod SYSTEM_BUILD_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build CHECKSUM_HACK=kprobe
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/misc
    cp kmod/mimic.ko $out/lib/modules/${kernel.modDirVersion}/misc/
    runHook postInstall
  '';
}
