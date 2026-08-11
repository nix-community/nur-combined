/*

WONTFIX s2e-klee fails to compile with llvmPackages_11

/build/source/klee/include/klee/util/GetElementPtrTypeIterator.h:135:71: error: no member named 'getIndices' in 'llvm::ConstantExpr'
    return vce_type_iterator::begin(CE->getOperand(0)->getType(), CE->getIndices().begin());
                                                                  ~~  ^

s2e-klee was forked from https://github.com/klee/klee on 2009-03-15

commit f2822ba876defa890c06e179b6f015b9d483c719
Author: Daniel Dunbar <daniel@zuster.org>
Date:   Sun Mar 15 05:28:32 2009 +0000

llvm 2.5.0 was released on 2009-03-11

oldest llvm in nixpkgs is llvm 11

*/

{ lib
, llvmPackages
, s2e
, cmake
, pkg-config
, boost
, libllvm
, libxml2
, libffi
, z3
, zlib
, ncurses
}:

llvmPackages.stdenv.mkDerivation rec {
  pname = "s2e-klee";
  inherit (s2e) version src;

  patchPhase = ''
    # note: stay in this directory for build
    cd klee

    substituteInPlace CMakeLists.txt \
      --replace-fail 'if (NOT LLVM_ENABLE_EH)' 'if (false)' \
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  cmakeFlags = [
    "-DENABLE_SOLVER_Z3=ON"
    "-DENABLE_UNIT_TESTS=OFF"
    # fix: /build/source/klee/lib/Support/PagePool.cpp:42:9: error: cannot use 'throw' with exceptions disabled
    #"-DLLVM_ENABLE_EH=1"
  ];

  postBuild = ''
    set -x
    find . -name '*.a' -or -name '*.so*'
    set +x
  '';

  buildInputs = [
    libllvm
    libxml2
    libffi
    z3
    zlib
    ncurses
    # fix: /build/source/klee/include/klee/Expr.h:20:10: fatal error: 'boost/intrusive_ptr.hpp' file not found
    boost
  ];

  propagatedBuildInputs = [
    boost
  ];
}
