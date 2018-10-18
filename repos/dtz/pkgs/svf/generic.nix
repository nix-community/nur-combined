{ stdenv, srcinfo, llvm, cmake }:

with stdenv.lib;
with srcinfo;
let
  llvm_version = getVersion llvm;
in
args: stdenv.mkDerivation (rec {
  name = "SVF-${llvm_version}-${version}";
  inherit version src;

  enableParallelBuilding = true;

  # For some reason SVF wants "LLVM_DIR" as an environment variable:
  preConfigure = ''
    export LLVM_DIR=${llvm}
  '';

  patches = [
    #./fix-consg-edge-del.patch
    ./svfg-crash-fix.patch
  ];

  # Without this, tools aren't built (or installed)
  cmakeFlags = [ "-DLLVM_BUILD_TOOLS=ON" "-DCMAKE_POSITION_INDEPENDENT_CODE=ON" ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [ llvm ];

  meta = with stdenv.lib; {
    description = "Pointer Analysis and Program Dependence Analysis for C and C++ Programs";
    maintainers = with maintainers; [ dtzWill ];
    license = licenses.gpl3Plus;
  };
} // args)

