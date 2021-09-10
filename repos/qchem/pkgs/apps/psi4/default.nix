{ lib, buildPythonPackage, buildPackages, makeWrapper, fetchFromGitHub, fetchurl, pkg-config
, writeTextFile, cmake, perl, gfortran, python, pybind11, qcelemental, qcengine, numpy, pylibefp
, deepdiff, mkl, gau2grid, libxc, dkh, dftd3, pcmsolver, libefp, chemps2, hdf5, hdf5-cpp
, pytest, mpfr, gmpxx, eigen, boost
} :

let
  # Psi4 requires some special cmake flags. Using Nix's defaults usually does not work.
  specialInstallCmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DNAMESPACE_INSTALL_INCLUDEDIR=/"
    "-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF"
    "-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF"
    "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  chemps2_ = chemps2.overrideAttrs (oldAttrs: rec {
    configurePhase = ''
      cmake -Bbuild ${toString specialInstallCmakeFlags}
      cd build
    '';
  });

  dkh_ = dkh.overrideAttrs (oldAttrs: rec {
    enableParallelBuilding = true;
    configurePhase = "cmake -Bbuild ${toString (oldAttrs.cmakeFlags ++ specialInstallCmakeFlags)}";
    preBuild = "cd build";
  });

  pcmsolver_ = pcmsolver.overrideAttrs (oldAttrs: rec {
    enableParallelBuilding = true;
    configurePhase = ''
      cmake -Bbuild ${toString (oldAttrs.cmakeFlags ++ specialInstallCmakeFlags)}
      cd build
    '';
  });

  libintSrc = fetchurl {
    url = "https://github.com/loriab/libint/releases/download/v0.1/Libint2-export-7-7-4-7-7-5_1.tgz";
    sha256 = "16vgnjpspairzm72ffjc8qb1qz0vwbx1cq237mc3c79qvqlw2zmn";
  };

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
    version = "1.4";

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
      libxc
      mkl
      dkh_
      pcmsolver_
      libefp
      chemps2_
      hdf5
      hdf5-cpp
      eigen
      mpfr
      gmpxx
      boost
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

    src = fetchFromGitHub {
      repo = pname;
      owner = "psi4";
      rev = "v${version}";
      sha256 = "WmK5EndhUQlHMPBdU/Y5iWgMpc8ZeoEhKU4SLdqwvxM=";
    };

    patches = [ ./LibintCmake.patch ];

    # Required for Libint compilation. g++ will otherwise not be able to link the large amount of files.
    preConfigure = ''
      ulimit -s 65536
    '';

    # Must be done after configuration unfortunately. Directories are overridden otherwise.
    postConfigure = ''
      cp ${libintSrc} external/upstream/libint2/libint2_external-prefix/src/Libint2-export-7-7-4-7-7-5_1.tgz
    '';

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
      # libint. Force to build within Psi4's own CMake system. It requires that many tunings
      # compared to the upstream version, that everything else is just wasting time.
      "-DMAX_AM_ERI=7"
      "-DBUILD_SHARED_LIBS=ON"
      "-DCMAKE_DISABLE_FIND_PACKAGE_Libint=ON"
      # libxc
      "-DCMAKE_INSIST_FIND_PACKAGE_Libxc=ON"
      "-DLibxc_DIR=${libxc}/share/cmake/Libxc"
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
      "-DCMAKE_PREFIX_PATH=\"${gau2grid};${libxc};${qcelemental};${pcmsolver_};${dkh_};${libefp};${chemps2_}\""
    ];

    format = "other";
    enableParallelBuilding = true;

    configurePhase = ''
      runHook preConfigure

      cmake -Bbuild ${toString cmakeFlags} -DCMAKE_INSTALL_PREFIX=$out
      cd build

      runHook postConfigure
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
      maintainers = [ maintainers.sheepforce ];
    };
  }
