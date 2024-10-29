{
  kernel,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "pico-rng";
  src = fetchFromGitHub {
    owner = "oluceps";
    repo = finalAttrs.name;
    rev = "16173a7c0b9f2c97816fddd583686ccaa6385656";
    hash = "sha256-pynB5nYHFz5drlQMvSaTG6up2xSQMdXbnVhNvr+fcnE=";
  };

  sourceRoot = "${finalAttrs.src.name}/driver";
  buildPhase = ''
    runHook preBuild
    mkdir -p $out/src
    cp pico_rng.c $out/src
    cp Kbuild $out/src
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$out/src modules
    runHook postBuild
  '';
  nativeBuildInputs = kernel.moduleBuildDependencies;
  installPhase = ''
    install -D $out/src/pico_rng.ko $out/lib/modules/${kernel.modDirVersion}/drivers/pico_rng.ko
    rm -r $out/src
  '';
})
