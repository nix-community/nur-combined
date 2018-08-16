{ stdenv
, fetchFromGitHub
, llvm
, python
, capstone
, cmake
, rev
, sha256
, version
, ...
}:

assert stdenv.cc.isClang;

stdenv.mkDerivation rec {
  inherit version;
  name = "fcd-${version}";

  src = fetchFromGitHub {
    owner = "zneak";
    repo = "fcd";
    inherit rev sha256;
  };

  buildInputs = [ llvm python capstone cmake ];

  patchPhase = ''
    sed -i 's,-isystem ''${LLVM_INCLUDE_DIRS},-isystem ''${LLVM_INCLUDE_DIRS} -isystem ${stdenv.cc.cc}/include,' CMakeLists.txt
    sed -i 's,PRIVATE ''${LLVM_INCLUDE_DIRS},PRIVATE ''${LLVM_INCLUDE_DIRS} ${stdenv.cc.cc}/include,' CMakeLists.txt
  '';

  enableParallelBuilding = true;

  installPhase = ''
    mkdir -p $out/bin
    cp fcd $out/bin/

    mkdir -p $out/share/fcd/scripts
    cp ../scripts/*py $out/share/fcd/scripts
  '';

  meta = with stdenv.lib; {
    description = "An optimizing decompiler";
    homepage = https://zneak.github.io/fcd;
    license = licenses.ncsa;
    maintainers = with maintainers; [ dtzWill ];
    platforms = platforms.all;
  };
}
