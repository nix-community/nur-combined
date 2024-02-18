{ kernel, stdenv, fetchFromGitHub }:
stdenv.mkDerivation (finalAttrs: {
  name = "tcp-brutal";
  src = fetchFromGitHub {
    owner = "apernet";
    repo = finalAttrs.name;
    rev = "eaa1068184a485b2b53bf3d4c90c1a08d9eb209b";
    hash = "sha256-8jIYFj+IH+Uz3RpjX+Tw4hFOS3/bc2v1ebsdRtGgeuA=";
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
