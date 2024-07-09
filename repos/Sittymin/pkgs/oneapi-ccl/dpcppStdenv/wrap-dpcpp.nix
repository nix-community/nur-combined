{ pkgs
, wrapCCWith
, gcc
, stdenv
, ...
}:
let
  dpcpp-unwrapped = pkgs.callPackage ./dpcpp.nix {
    inherit (pkgs) stdenv;
  };
  bintools = pkgs.callPackage ./bintools-unwrapped.nix { };
in
let
  cc = dpcpp-unwrapped;
in
(wrapCCWith {
  inherit cc bintools;
  extraBuildCommands = ''
    wrap icx $wrapper $ccPath/icx
    wrap icpx $wrapper $ccPath/icpx
    wrap dpcpp $wrapper $ccPath/dpcpp

    # Disable hardening by default
    echo "" > $out/nix-support/add-hardening.sh

    # mkdir -p $out/resource-root
    # ln -s ${cc}/lib/clang/17/{include, lib} $out/resource-root
  '';

  nixSupport = {
    cc-cflags = [
      "-isystem ${cc}/include"
      "-isystem ${cc}/include/compiler"
      "-isystem ${cc}/lib/clang/17/include"
      # "-B${cc}/lib/clang/17"

      "--gcc-toolchain=${gcc.cc}"
      # "--gcc-install-dir=${gcc.cc}"
      # for e.g. openmp: omp.h
      # "-isystem ${gcc.cc}/lib/gcc/${stdenv.targetPlatform.config}/${gcc.version}/include"
      # "-isystem ${gcc.cc}/lib/gcc/${stdenv.targetPlatform.config}/${gcc.version}/include-fixed"

      # "-resource-dir=$out/resource-root"
      # "-nostdinc"
    ];

    cc-ldflags = [
      "-L${cc}/lib"
      "-L${gcc.cc}/lib/gcc/${stdenv.targetPlatform.config}/${gcc.version}"
      "-L${gcc.cc.lib}/lib"
    ];

    setup-hook = [
      "export ONEAPI_ROOT=${cc}"
    ];
  };

  # extraPackages = [cc];
}).overrideAttrs (old: {
  installPhase =
    old.installPhase
    + ''
      export named_cc="icx"
      export named_cxx="icpx"
    '';
})
