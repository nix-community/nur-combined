selfPkgs: superPkgs: self: super:

let
  callPackage = self.callPackage;

in {
  pyscf = callPackage ./pyscf { };
  pyquante = callPackage ./pyquante { };
  pychemps2 = callPackage ./chemps2/PyChemMPS2.nix { };
  qcelemental = callPackage ./qcelemental { };
  qcengine = callPackage ./qcengine { };
  gau2grid-1_3_1 = callPackage ./gau2grid { version = "1.3.1"; sha256 = "0zkfil7cxjip79wqvhljk1ifjq0cwxzx6wlxgp63b6wbagma0i12"; };
  gau2grid-2_0_4 = callPackage ./gau2grid { version = "2.0.4"; sha256 = "0qypq8iax0n6yfi4223zya468v24b60nr0x43ypmsafj0104zqa6"; };
  gau2grid = callPackage ./gau2grid { };
  pylibefp = callPackage ./pylibefp { };
  psi4 = callPackage ./psi4 {
    blas = superPkgs.blas.override { blasProvider = superPkgs.mkl; };
    lapack = superPkgs.lapack.override { lapackProvider = superPkgs.mkl; };
    gau2grid = self.gau2grid-1_3_1;
  };
  psi4Unstable = callPackage ./psi4 {
    blas = superPkgs.blas.override { blasProvider = superPkgs.mkl; };
    lapack = superPkgs.lapack.override { lapackProvider = superPkgs.mkl; };
    gau2grid = self.gau2grid-2_0_4;
    version = "01.11.2020";
    rev = "9b60184c5d161e4871c91ce29a44e3ac2c2a438e";
    sha256 = "1vh8dp3nw4fk1mnfv0w8ici1lzxyfn5han7hipqzsfxl75w76r18";
  };
}
