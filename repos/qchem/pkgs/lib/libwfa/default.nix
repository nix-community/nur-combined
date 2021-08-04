{ stdenv, lib, fetchFromGitHub, cmake
, buildMolcasLib ? false
, buildMolcasExe ? false
, armadillo, blas, hdf5-cpp
} :

# Won't build together
assert buildMolcasExe -> !buildMolcasLib;

let
  libName = if buildMolcasLib == true
    then "libwfa_molcas.a"
    else "libwfa.a";

in stdenv.mkDerivation rec {
  pname = "libwfa";
  version = "2020-02-19";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "f1d102d6c18aa1de72e8cb8707f2d40918392ed9";
    sha256 = "1ncx870jkpy86x6ppc8ccxjagb9bja8x7rk296hsmndsjhkca1ff";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ armadillo blas hdf5-cpp ];

  CXXFLAGS = [ "-DH5_USE_110_API" ];

  cmakeFlags = [ "-DARMA_HEADER=ON" ]
    ++ lib.optional buildMolcasLib "-DMOLCAS_LIB=ON"
    ++ lib.optional buildMolcasExe "-DMOLCAS_EXE=ON";

  installPhase = ''
    find
    mkdir -p $out/lib
    install -m 644 ./libwfa/${libName} $out/lib
  '' + lib.optionalString buildMolcasExe ''
    mkdir -p $out/bin
    install -m 755 ./libwfa/molcas/wfa_molcas.x $out/bin
  '';

  meta = with lib; {
    description = "Wave-function analysis tool library for quantum chemical applications";
    homepage = "https://github.com/libwfa/libwfa";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}

