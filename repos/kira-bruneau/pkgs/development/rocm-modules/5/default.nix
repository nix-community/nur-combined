pkgs: final: prev:

with final;

let
  callPackage = pkgs.newScope final;
in
{
  inherit callPackage;

  rocfft = callPackage ./rocfft {
    inherit (llvm) openmp;
    stdenv = llvm.rocmClangStdenv;
  };
}
