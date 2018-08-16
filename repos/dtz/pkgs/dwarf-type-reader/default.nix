{ stdenv
, fetchFromGitHub
, llvm
, protobuf
, cmake
}:

stdenv.mkDerivation rec {
  version = "2017-08-21";
  name = "dwarf-type-reader-${version}";

  src = fetchFromGitHub {
    owner = "sdasgup3";
    repo = "dwarf-type-reader";
    rev = "b95a6e6d122ad27c532218d1d78b164025106a64";
    sha256 = "0vkrapvcajp0m3p7hxirnj087sp25xkzx4xp40v20mc1x4bqfdjv";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ llvm protobuf ];

  cmakeFlags = [
    "-DLLVM_ROOT=${llvm}"
    "-DLLVM_BUILD_TOOLS=ON"
    "-DLLVM_ENABLE_RTTI=ON"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Reading type information from debug info section of executable";
    homepage = https://github.com/sdasgup3/dwarf-type-reader;
    license = licenses.mit;
    maintainers = with maintainers; [ dtzWill ];
  };
}
