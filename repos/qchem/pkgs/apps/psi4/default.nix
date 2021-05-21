{ lib, buildPythonPackage, buildPackages, makeWrapper, fetchFromGitHub, pkg-config, writeTextFile
# Build time dependencies
, cmake
, perl
, gfortran
# Runtime dependencies
, python
, pybind11
, qcelemental
, qcengine
, numpy
, pylibefp
, deepdiff
, blas
, lapack
, gau2grid
, libint1
, libxc
, dkh
, dftd3
, pcmsolver
, libefp
, chemps2
, hdf5
, hdf5-cpp
, pytest
, version ? "1.3.2"
, rev ? "v${version}"
, sha256 ? "07jyg67hv9qaj1wsjhkczpx6h5lq2ffw84n0x17vf6zzmpcgc4l9"
}:
assert
  lib.asserts.assertMsg
  (blas.passthru.implementation == "mkl")
  "MKL must be used as BLAS provider.";

assert
  lib.asserts.assertMsg
  (lapack.passthru.implementation == "mkl")
  "MKL must be used as LAPACK provider";

let
  blas_ = blas.passthru.provider;
  lapack_ = lapack.passthru.provider;

  # Psi4 requires some special cmake flags. Using Nix's defaults usually does not work.
  specialInstallCmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DNAMESPACE_INSTALL_INCLUDEDIR=/"
    "-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF"
    "-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF"
    "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  # Only builds with specific commit and special CMakeFlags..
  libint1_ = libint1.overrideAttrs (oldAttrs: rec {
    version = "1.2.1-psi4";
    src = fetchFromGitHub {
      owner = "evaleev";
      repo = oldAttrs.pname;
      rev = "b13e71d3cf9960460c4019e5ecf2546a5f361c71";
      sha256 = "1k05b3q14hppsc4n50jx19ikp8rbhwkrkhmp0wjic2z7g7ydra37";
    };

    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ cmake ];
    cmakeFlags = [
      "-DBUILD_FPIC=ON"
      "-DENABLE_XHOST=OFF"
      "-DMAX_AM_ERI=7"
      "-DBUILD_SHARED_LIBS=ON"
      "-DCMAKE_BUILD_TYPE=RELEASE"
      "-DENABLE_GENERIC=ON"
      "-DMERGE_LIBDERIV_INCLUDEDIR=OFF"
      "-DCMAKE_INSTALL_PREFIX=$out"
    ];

    configurePhase = ''
      cmake -Bbuild ${toString (cmakeFlags ++ specialInstallCmakeFlags)}
      cd build
    '';

    # Psi4 expects the headers in a different location.
    postInstall = ''
      cp $out/include/libderiv/libderiv.h $out/include/libint/.
    '';
  });

  # Require special CMake flags to be found by Psi4.
  chemps2_ = chemps2.overrideAttrs (oldAttrs: rec {
    configurePhase = ''
      cmake -Bbuild ${toString specialInstallCmakeFlags}
      cd build
    '';
  });

  dkh_ = dkh.overrideAttrs (oldAttrs: rec {
    enableParallelBuilding = true;
    configurePhase = ''
      cmake -Bbuild ${toString (oldAttrs.cmakeFlags ++ specialInstallCmakeFlags)}
      cd build
    '';
  });

  pcmsolver_ = pcmsolver.overrideAttrs (oldAttrs: rec {
    enableParallelBuilding = true;
    configurePhase = ''
      cmake -Bbuild ${toString (oldAttrs.cmakeFlags ++ specialInstallCmakeFlags)}
      cd build
    '';
  });

  libxc_ = libxc.overrideAttrs (oldAttrs: rec {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ cmake ];

    enableParallelBuilding = true;

    configurePhase = ''
      cmake -Bbuild ${toString specialInstallCmakeFlags}
      cd build
    '';
  });

  testInputs = {
    h2o_omp25_opt = writeTextFile {
      name = "h2o_omp25_opt";
      text = ''
        memory 1 GB
        molecule Water {
        0 1
        O
        H 1 0.8
        H 1 0.8 2 110
        }

        set {
        basis cc-pvdz
        scf_type df
        mp_type df
        reference rhf
        }

        optimize("omp2.5")
      '';
    };
  };


in buildPythonPackage rec {
    pname = "psi4";
    inherit version;

    nativeBuildInputs = [
      cmake
      perl
      gfortran
      makeWrapper
      pkg-config
      pytest
    ];

    buildInputs = [
      gau2grid
      libint1_
      libxc
      blas_
      lapack_
      dkh_
      pcmsolver_
      libefp
      chemps2_
      hdf5
      hdf5-cpp
    ];

    propagatedBuildInputs = [
      pybind11
      qcelemental
      qcengine
      numpy
      pylibefp
      deepdiff
      dftd3
      chemps2_
    ] ++ qcelemental.passthru.requiredPythonModules
      ++ qcengine.passthru.requiredPythonModules
    ;

    checkInputs = [
      pytest
    ];

    src = fetchFromGitHub  {
      inherit rev sha256;
      owner = "psi4";
      repo = pname;
    };

    cmakeFlags = [
      "-DDCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF"
      "-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF"
      "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
      "-DCMAKE_INSTALL_PREFIX=$out"
      "-DBUILD_SHARED_LIBS=ON"
      "-DENABLE_XHOST=OFF"
      "-DENABLE_OPENMP=ON"
      # gau2grid
      "-DCMAKE_INSIST_FIND_PACKAGE_gau2grid=ON"
      "-Dgau2grid_DIR=${gau2grid}/share/cmake/gau2grid"
      # libint
      "-DCMAKE_INSIST_FIND_PACKAGE_Libint=ON"
      "-DLibint_DIR=${libint1_}/share/cmake/Libint"
      # libxc
      "-DCMAKE_INSIST_FIND_PACKAGE_Libxc=ON"
      "-DLibxc_DIR=${libxc_}/share/cmake/Libxc"
      # pcmsolver
      "-DCMAKE_INSIST_FIND_PACKAGE_PCMSolver=ON"
      "-DENABLE_PCMSolver=ON"
      "-DPCMSolver_DIR=${pcmsolver_}/share/cmake/PCMSolver"
      # DKH
      "-DENABLE_dkh=ON"
      "-DCMAKE_INSIST_FIND_PACKAGE_dkh=ON"
      "-Ddkh_DIR=${dkh_}/share/cmake/dkh"
      # LibEFP
      "-DENABLE_libefp=ON"
      # CheMPS2
      "-DENABLE_CheMPS2=ON"
      # Prefix path for all external packages
      "-DCMAKE_PREFIX_PATH=\"${gau2grid};${libint1_};${libxc_};${qcelemental};${pcmsolver_};${dkh_};${libefp};${chemps2_}\""
    ];

    format = "other";
    enableParallelBuilding = true;

    configurePhase = ''
      cmake -Bbuild ${toString cmakeFlags} -DCMAKE_INSTALL_PREFIX=$out
      cd build
    '';

    postFixup = let
      binSearchPath = with lib; strings.makeSearchPath "bin" [ dftd3 ];

    in ''
      # Make libraries and external binaries available
      wrapProgram $out/bin/psi4 \
        --prefix PATH : ${binSearchPath}

      # Symlinks so that the lib directory is easy to find for python.
      mkdir -p $out/lib/${python.executable}/site-packages
      ln -s $out/lib/psi4 $out/lib/${python.executable}/site-packages/.

      # The symlink needs a fix for the PSIDATADIR on python side as its expecting to be installed
      # somewhere else.
      substituteInPlace $out/lib/${python.executable}/site-packages/psi4/__init__.py \
        --replace 'elif "CMAKE_INSTALL_DATADIR" in data_dir:' 'else:' \
        --replace 'data_dir = os.path.sep.join([os.path.abspath(os.path.dirname(__file__)), "share", "psi4"])' 'data_dir = "@out@/share/psi4"' \
        --subst-var out
    '';

    doCheck = false;
    checkPhase = ''
      runHook preCheck
      ctest -j $NIX_BUILD_CORES
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      export OMP_NUM_THREADS=2
      $out/bin/psi4 -i ${testInputs.h2o_omp25_opt} -o out1.out -n 2 && grep "Final energy is    -76.235085" out1.out
    '';

    meta = with lib; {
      description = "Open-Source Quantum Chemistry – an electronic structure package in C++ driven by Python";
      homepage = "http://www.psicode.org/";
      license = licenses.lgpl3;
      platforms = platforms.linux;
    };
  }
