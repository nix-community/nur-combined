{
  sources,
  lib,
  stdenv,
  cmake,
  pkg-config,
  hwloc,
  llvmPackages,
  lttng-ust,
  ocl-icd,
  python3,
  runCommand,
  makeWrapper,
}:
# Modified from https://github.com/NixOS/nixpkgs/pull/261736
let
  clang = llvmPackages.clangUseLLVM;
  clangWrapped = runCommand "clang-pocl" { nativeBuildInputs = [ makeWrapper ]; } ''
    mkdir -p $out/bin
    cp -r ${clang}/bin/* $out/bin/

    LIBGCC_DIR=$(dirname $(find ${stdenv.cc.cc}/lib/ -name libgcc.a))

    for F in ${clang}/bin/ld*; do
      BASENAME=$(basename "$F")
      rm -f $out/bin/$BASENAME
      makeWrapper ${clang}/bin/$BASENAME $out/bin/$BASENAME \
        --add-flags "-L$LIBGCC_DIR" \
        --add-flags "-L${stdenv.cc.cc.lib}/lib"
    done
  '';
in
stdenv.mkDerivation rec {
  inherit (sources.pocl) pname version src;

  cmakeFlags = [
    "-DKERNELLIB_HOST_CPU_VARIANTS=distro"
    # avoid the runtime linker pulling in a different llvm e.g. from graphics drivers
    "-DLLVM_STATIC=ON"
    "-DENABLE_POCL_BUILDING=OFF"
    "-DPOCL_ICD_ABSOLUTE_PATH=ON"
    "-DENABLE_ICD=ON"
    "-DCLANG=${clangWrapped}/bin/clang"
    "-DCLANGXX=${clangWrapped}/bin/clang++"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    clangWrapped
    python3
  ];

  buildInputs = [
    hwloc
    llvmPackages.llvm
    llvmPackages.libclang
    lttng-ust
    ocl-icd
  ];

  meta = {
    changelog = "https://github.com/pocl/pocl/releases/tag/v${version}";
    mainProgram = "poclcc";
    description = "Portable OpenCL standard implementation";
    homepage = "http://portablecl.org";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      jansol
      xddxdd
    ];
    knownVulnerabilities = [
      "${pname} is available in nixpkgs"
    ];
    platforms = [ "x86_64-linux" ];
  };
}
