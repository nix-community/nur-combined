{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
}:

stdenv.mkDerivation {
  name = "ideapad-laptop-tb-${kernel.version}";

  passthru.moduleName = "ideapad-laptop-tb";

  hardeningDisable = [ "pic" ];

  src = fetchFromGitHub {
    owner = "ferstar";
    repo = "ideapad-laptop-tb";
    rev = "efbc768ad404c3beb8ed988127c8ae05d5608f6b";
    hash = "sha256-DiHwkvU6y1O2Cgl4Y3v+Yq5eIIdeyIZgxQ0KEwAxloM=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  installPhase = ''
    install -D ideapad-laptop-tb.ko $out/lib/modules/${kernel.modDirVersion}/misc/ideapad-laptop-tb.ko
  '';
}
