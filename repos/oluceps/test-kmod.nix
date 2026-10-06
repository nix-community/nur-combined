{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation {
  pname = "mimic-kmod";
  version = "unstable";
  src = fetchFromGitHub {
    owner = "hack3ric";
    repo = "mimic";
    rev = "b1f0701b90b7a070e3aa2bd701ee409f79353824";
    sha256 = "19y11akj67n3x0gna08wrrip4kv110m5jzp5mbicwsb6ay0vaw72";
  };
  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "build-kmod"
  ];
}
