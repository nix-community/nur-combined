{ fetchFromGitHub, stdenv }:

let kernel_gcc_patch = stdenv.mkDerivation {
  name = "kernel_gcc_patch";
  src = fetchFromGitHub {
    owner = "graysky2";
    repo = "kernel_gcc_patch";
    rev = "547932b1146cdd7b25eca8fb3449f6af2ea81726";
    sha256 = "0b6yxm8di64ps4c87j3kj90wf05834w49ad57bq35lrpzxf54gr4";
  };
  installPhase = ''
    mkdir -p $out/lib
    mv ./* $out/lib
  '';
}; in

{ name = "gcc_patch";
  patch = builtins.toPath "${kernel_gcc_patch}/lib/enable_additional_cpu_optimizations_for_gcc_v9.1+_kernel_v4.13+.patch";
}
