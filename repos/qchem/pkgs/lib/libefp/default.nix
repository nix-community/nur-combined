{ lib, stdenv, fetchFromGitHub, cmake, gfortran
# Dependencies
, blas
, lapack
# Config
, fraglib_deep ? false
, fraglib_underscore_l ? false
, psi4_patches ? true
, version ? "1.5.0-psi4"
, rev ? "15cd7ce91239c04b5c32ed101bde6cc36c57550a"
, sha256 ? "0jcvl3chni4f0hddx9blaia3kccfqx7cszrwavp0a35d42n0x5i2"
}:
assert
  lib.asserts.assertMsg
  (!blas.isILP64)
  "32 bit integer BLAS implementation required.";

stdenv.mkDerivation rec {
    pname = "libefp";
    inherit version;

    nativeBuildInputs = [
      cmake
      gfortran
    ];

    buildInputs = [
      blas
      lapack
    ];

    src = fetchFromGitHub {
      owner = "ilyak";
      repo = pname;
      inherit rev sha256;
    };

    cmakeFlags = [
      "-DCMAKE_INSTALL_PREFIX=$out"
      "-DNAMESPACE_INSTALL_INCLUDEDIR=/"
      "-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF"
      "-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF"
      "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
      "-DCMAKE_SKIP_BUILD_RPATH=ON"
      "-DFRAGLIB_DEEP=${if fraglib_deep then "ON" else "OFF"}"
      "-DFRAGLIB_UNDERSCORE_L=${if fraglib_underscore_l then "ON" else "OFF"}"
      "-DENABLE_OPENMP=ON"
      "-DINSTALL_DEVEL_HEADERS=ON"
      "-DBUILD_SHARED_LIBS=ON"
    ];

    # It is probably suboptiomal to completely override the cmakeFlags, but PyLibefp and Psi4 don't
    # work with the normal CMake setup of Nix.
    configurePhase = ''
      cmake -Bbuild ${toString cmakeFlags}
      cd build
    '';

    hardeningDisable = [
      "format"
    ];

    meta = with lib; {
      description = "Parallel implementation of the Effective Fragment Potential Method";
      homepage = "https://github.com/ilyak/libefp";
      license = licenses.bsd3;
      platforms = platforms.unix;
    };
  }
