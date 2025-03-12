{ lib, stdenv, fetchFromGitHub
, libpng, gzip, fftw, blas, lapack
, withMPI ? false
, mpi
, withOneAPI ? false
, procps
, glibc
, intel-oneapi
, gcc
}:
let packages = [
     "asphere" "body" "class2" "colloid" "compress" "coreshell"
     "dipole" "granular" "kspace" "manybody" "mc" "misc" "molecule"
     "opt" "peri" "qeq" "replica" "rigid" "shock" "srd"
    ];
    lammps_includes = "-DLAMMPS_EXCEPTIONS -DLAMMPS_GZIP -DLAMMPS_MEMALIGN=64";
in
stdenv.mkDerivation rec {
  # LAMMPS has weird versioning converted to ISO 8601 format
  version = "stable_29Sep2021_update2";
  pname = "lammps";

  src = fetchFromGitHub {
    owner = "lammps";
    repo = "lammps";
    rev = version;
    sha256 = "1ihrg6fw2c2dmgjh6ls9c16sd7mymhsigqwjgn5kjmk81z68kb52";
  };

  passthru = {
    inherit mpi;
    inherit packages;
  };

  nativeBuildInputs = [ procps glibc ];

  enableParallelBuilding = true;

  buildInputs = [ fftw libpng blas lapack gzip gcc ]
    ++ (lib.optionals withMPI [ mpi ])
    ++ (lib.optionals withOneAPI [ intel-oneapi ]);

  configurePhase = ''
    cd src
    ${if withOneAPI then "source ${intel-oneapi}/setvars.sh" else ""}
    for pack in ${lib.concatStringsSep " " packages}; do make "yes-$pack" SHELL=$SHELL; done
  '';

  # Must do manual build due to LAMMPS requiring a seperate build for
  # the libraries and executable. Also non-typical make script
  buildPhase = ''
    COMPILER=${if withOneAPI then "oneapi" else "cc"}
    if [ "$COMPILER" = "oneapi" ]
    then 
      export GCCROOT=${gcc}
      export GXXROOT=${gcc}
      # Explicitly include C++ headers to prevent errors where stdlib.h is not found from cstdlib.
      EXTRA_INC="-isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version} -isystem ${stdenv.cc.cc}/include/c++/${stdenv.cc.version}/x86_64-unknown-linux-gnu $NIX_CFLAGS_COMPILE";
      make mode=exe -j$NIX_BUILD_CORES intel_cpu_intelmpi SHELL=$SHELL LMP_INC="${lammps_includes} $EXTRA_INC" FFT_PATH=-DFFT_FFTW3 FFT_LIB=-lfftw3 JPG_LIB=-lpng LINK="mpiicpc -std=c++11 $EXTRA_INC"
      make mode=shlib -j$NIX_BUILD_CORES intel_cpu_intelmpi SHELL=$SHELL LMP_INC="${lammps_includes} $EXTRA_INC" FFT_PATH=-DFFT_FFTW3 FFT_LIB=-lfftw3 JPG_LIB=-lpng LINK="mpiicpc -std=c++11 $EXTRA_INC"
    else
      make mode=exe ${if withMPI then "mpi" else "serial"} SHELL=$SHELL LMP_INC="${lammps_includes}" FFT_PATH=-DFFT_FFTW3 FFT_LIB=-lfftw3 JPG_LIB=-lpng
      make mode=shlib ${if withMPI then "mpi" else "serial"} SHELL=$SHELL LMP_INC="${lammps_includes}" FFT_PATH=-DFFT_FFTW3 FFT_LIB=-lfftw3 JPG_LIB=-lpng
    fi
  '';

  installPhase = ''
    mkdir -p $out/bin $out/include $out/lib

    cp -v lmp_* $out/bin/
    cp -v *.h $out/include/
    cp -v liblammps* $out/lib/
  '';

  meta = with lib; {
    description = "Classical Molecular Dynamics simulation code";
    longDescription = ''
      LAMMPS is a classical molecular dynamics simulation code designed to
      run efficiently on parallel computers. It was developed at Sandia
      National Laboratories, a US Department of Energy facility, with
      funding from the DOE. It is an open-source code, distributed freely
      under the terms of the GNU Public License (GPL).
      '';
    homepage = "https://lammps.sandia.gov";
    #license = licenses.gpl2Plus;
    license = lib.licenses.unfree; # prevent NUR ci from building it (OneAPI version)
    platforms = platforms.linux;
    maintainers = [ maintainers.costrouc ];
  };
}
