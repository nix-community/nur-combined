final: prev: self: optStdenv:

#
# Package set with upstream libraries
# and optimizations of upstream packages
#

with final;
let
  hp = optStdenv.hostPlatform;

  # like callPackage but with override instead
  recallPackage = pkg: inputs:
    pkg.override ((builtins.intersectAttrs pkg.override.__functionArgs set) // inputs);

  set = {
    stdenv = optStdenv;
    cp2k = recallPackage cp2k {};
    dkh = recallPackage dkh {};
    ergoscf = recallPackage ergoscf {};
    hpl = recallPackage hpl {};
    hpcg = recallPackage hpcg {};
    i-pi = recallPackage i-pi {};
    gsl = recallPackage gsl {};
    libvori = recallPackage libvori {};
    libxc = recallPackage libxc {};
    mkl = recallPackage mkl {};
    molden = recallPackage molden {};
    mpi = recallPackage mpi {};
    octopus = recallPackage octopus {};
    quantum-espresso = recallPackage quantum-espresso {};
    quantum-espresso-mpi = recallPackage quantum-espresso-mpi {};
    pcmsolver = recallPackage pcmsolver {};
    scalapack = recallPackage scalapack {};
    siesta = recallPackage siesta {};
    siesta-mpi = recallPackage siesta-mpi {};
    spglib = recallPackage spglib {};

    fftw = (recallPackage fftw {}).overrideAttrs ( oldAttrs: {
      configureFlags = with lib; oldAttrs.configureFlags
        ++ optional hp.avxSupport "--enable-avx"
        ++ optional hp.avx2Support "--enable-avx2"
        ++ optional hp.fmaSupport "--enable-fma"
        ++ optional (hp.fmaSupport && hp.avxSupport) "--enable-avx-128-fma";
      });

    fftwSinglePrec = self.fftw.override { precision = "single"; };

    fftw-mpi = self.fftw.overrideAttrs ( oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ self.mpi ];

      configureFlags = with lib.lists; oldAttrs.configureFlags ++ [
        "--enable-mpi"
      ];

      propagatedBuildInputs = oldAttrs.propagatedBuildInputs or [] ++ [ self.mpi ];
    });

    gromacs = recallPackage gromacs {
      cpuAcceleration = if hp.avx2Support then "AVX2_256" else null;
      fftw = self.fftwSinglePrec;
    };

    gromacsMpi = recallPackage gromacsMpi {
      cpuAcceleration = if hp.avx2Support then "AVX2_256" else null;
      fftw = self.fftwSinglePrec;
    };

    gromacsDouble = recallPackage gromacsDouble {
      cpuAcceleration = if hp.avx2Support then "AVX2_256" else null;
    };

    gromacsDoubleMpi = recallPackage gromacsDoubleMpi {
      cpuAcceleration = if hp.avx2Support then "AVX2_256" else null;
    };

    libint = recallPackage libint { enableFMA = hp.fmaSupport; };

    libxsmm = (recallPackage libxsmm {}).overrideAttrs ( x: {
      makeFlags = x.makeFlags or [] ++ [ "OPT=3" ]
        ++ lib.optional hp.avx2Support ["AVX=2" ];
    });

    hostPlatform = hp;
  };

in set
