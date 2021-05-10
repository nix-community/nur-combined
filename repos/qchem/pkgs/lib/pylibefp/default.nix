{ stdenv, lib, fetchFromGitHub, cmake
# Dependencies
, libefp
, blas
# Python
, python
, pybind11
, qcelemental
}:
stdenv.mkDerivation rec {
    pname = "pylibefp";
    version = "0.6.1";

    nativeBuildInputs = [
      cmake
    ];

    buildInputs = [
      blas
      libefp
    ];

    propagatedBuildInputs = [
      python
      pybind11
      qcelemental
    ];

    cmakeFlags = [
      "-DCMAKE_PREFIX_PATH=${libefp}"
      "-Dlibefp_DIR=${libefp}/share/cmake/libefp"
    ];

    src = fetchFromGitHub  {
      owner = "loriab";
      repo = pname;
      rev = "v${version}";
      sha256 = "01cl4byfj16iyv0b684z1jblsk66vhh2bdcfg75nhkspm6pmhz6a";
    };

    meta = with lib; {
      description = "Periodic table, physical constants, and molecule parsing for quantum chemistry.";
      license = licenses.bsd3;
      homepage = "http://docs.qcarchive.molssi.org/projects/qcelemental/en/latest/";
      platforms = platforms.unix;
    };
  }
