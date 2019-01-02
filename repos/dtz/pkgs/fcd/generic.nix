{ stdenv
, fetchFromGitHub
, llvm
, python
, capstone_3
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

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm python capstone_3 ];

  patchPhase = ''
    sed -i 's,-isystem ''${LLVM_INCLUDE_DIRS},\0 -isystem ${stdenv.cc.cc}/include,' CMakeLists.txt
    sed -i 's,PRIVATE ''${LLVM_INCLUDE_DIRS},\0 ${stdenv.cc.cc}/include,' CMakeLists.txt
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
