{
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
    rev = "45b1dc104290dbfef7ed1661055408998ef85a97";
    hash = "sha256-aDMjxlHeXPT0Yvya/92OOhGPWB32aTTrehr9yizMLkw=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  installPhase = ''
    install -D ideapad-laptop-tb.ko $out/lib/modules/${kernel.modDirVersion}/misc/ideapad-laptop-tb.ko
  '';
}
