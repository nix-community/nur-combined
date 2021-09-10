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
    avogadro2 = recallPackage avogadro2 {};
    cp2k = recallPackage cp2k {};
    fftw = recallPackage fftw {};
    dkh = recallPackage dkh {};
    ergoscf = recallPackage ergoscf {};
    hpl = recallPackage hpl {};
    hpcg = recallPackage hpcg {};
    i-pi = recallPackage i-pi {};
    gsl = recallPackage gsl {};
    libint = recallPackage libint {};
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

    fftwSinglePrec = self.fftw.override { precision = "single"; };

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

    libxsmm = (recallPackage libxsmm {}).overrideAttrs ( x: {
      makeFlags = x.makeFlags or [] ++ [ "OPT=3" ]
        ++ lib.optional hp.avx2Support ["AVX=2" ];
    });

    hostPlatform = hp;
  };

in set
