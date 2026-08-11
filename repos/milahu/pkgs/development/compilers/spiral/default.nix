{ lib
, stdenv
, runCommand
, fetchFromGitHub
, cmake
, python3
#, withCuda ? false # TODO
}:

let

  spiral = stdenv.mkDerivation rec {
    pname = "spiral";
    version = "8.5.1";

    # https://github.com/spiral-software/spiral-software
    src = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-software";
      rev = version;
      hash = "sha256-Gnt122wlj7r0lrUJcrRoUh7ETddsWXdnA969YRFz3fo=";
    };

    # resolve spiral packages from SPIRAL_DIR
    # allow a symlinked SPIRAL_DIR
    # https://github.com/spiral-software/spiral-software/issues/123
    patchPhase = ''
      substituteInPlace config/spiral.in config/spirald.in \
        --replace-fail \
          'SPIRAL="`dirname $0`/.."' \
          'SPIRAL="$SPIRAL_DIR"; [ -z "$SPIRAL" ] && SPIRAL="$(dirname "$0")/.."' \
    '';

    # spiral calls this SPIRAL_DIR
    # spiralpy calls this SPIRAL_HOME
    spiralDir = "opt/spiral";

    passthru = {
      inherit spiralDir;
      inherit spiralPackagesSrc;
    };

    nativeBuildInputs = [
      cmake
      python3
    ];

    buildInputs = [
      #cuda # TODO nvcc
    ];

    # compiled files are installed into the source tree
    # because the source tree contains other files required on runtime
    # so we install the source tree to $out/opt/spiral

    # TODO reduce file count
    postInstall = ''
      cd ..
      rm -rf build
      rm gap/bin/gap.bat
      chmod +x gap/bin/gap.sh
      mkdir -p $out/$spiralDir
      rmdir $out/$spiralDir
      cp -r . $out/$spiralDir
      mkdir -p $out/bin
      cat >$out/bin/spiral <<EOF
      #!/bin/sh
      export SPIRAL_DIR='$out/$spiralDir'
      exec \$SPIRAL_DIR/bin/spiral "\$@"
      EOF
      chmod +x $out/bin/spiral
    '';

    meta = with lib; {
      description = "generate platform-tuned implementations of digital signal processing (DSP) algorithms and other numerical kernels";
      longDescription = ''
        push the limits of automation in software and hardware development and optimization
        for digital signal processing (DSP) algorithms and other numerical kernels
        beyond what is possible with current tools.
      '';
      homepage = "https://spiral.net/";
      license = licenses.bsd2WithViews;
      maintainers = with maintainers; [ ];
      mainProgram = "spiral";
      platforms = platforms.all;
    };
  };

  # https://github.com/spiral-software?q=spiral-package
  spiralPackagesSrc = {

    # https://github.com/spiral-software/spiral-package-jit
    jit = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-jit";
      rev = "cf7c31320ef0fd9fe632f193335301695d2f6bcd";
      hash = "sha256-GJDyfYp82dGWWVyTQgFvD2zRBnw7qyjk0EVJevxEbT0=";
    };

    # https://github.com/spiral-software/spiral-package-fftx
    fftx = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-fftx";
      rev = "b492b241ded889712788c200b076add5d136b230";
      hash = "sha256-UwzqCG2hQD6o5iUxyJZgpF1XkTFh9mc5HvmOOBNNLis=";
    };

    # https://github.com/spiral-software/spiral-package-mpi
    mpi = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-mpi";
      rev = "5f2ba83f8b3126d0872086a43bb1a7b22e79c025";
      hash = "sha256-zeO2XkIrqNitAJIoIXj4ISs7jgDXekmNcRZdMl7jW+Y=";
    };

    # https://github.com/spiral-software/spiral-package-simt
    simt = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-simt";
      rev = "4380ed0a989dfbd7f99403e88e954deda6d7b77e";
      hash = "sha256-eoVChNS4uZmm5dnLcw2pVI0wfi1zxEfuOz1OD5DLGsU=";
    };

    # https://github.com/spiral-software/spiral-package-hcol
    hcol = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-hcol";
      rev = "b4a0118382e3bba91ecd82a6c667f2cdb6389ceb";
      hash = "sha256-HA9vqdoDI5EVUPOcJGpfAn5TVfekHHzCa9QVlMP509U=";
    };

    # https://github.com/spiral-software/spiral-package-quantum
    quantum = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-quantum";
      rev = "dd2323983495adbbc6261c0cdf840320d19d099d";
      hash = "sha256-eNIkJ2ygNCeu6BItTeUfGdOxhlLzwD/CBT76BQe5A2A=";
    };

    # https://github.com/spiral-software/spiral-package-ffte
    ffte = fetchFromGitHub {
      owner = "spiral-software";
      repo = "spiral-package-ffte";
      rev = "19f751776c117e28bdbcc3d2530c895ad554d855";
      hash = "sha256-N3j7DbY64ya3PNf5TQZyGrPIrOhEznnlDjnAzWK5A4I=";
    };

  };

in

runCommand
  "spiral-env-${spiral.version}"
  {
    pname = "spiral-env";
    inherit spiral;
    inherit (spiral)
      version
      meta
      spiralDir
    ;
  }
  # yeah i know this is simpler with lndir
  # but lndir creates symlinks for all files
  # which is a waste of inodes
  # here we only need to overlay
  # $out/$spiralDir/namespaces/packages/
  # everything else can be symlinked
  ''
    mkdir -p $out
    ln -s $spiral/bin $out

    mkdir -p $out/$spiralDir
    ln -s $spiral/$spiralDir/* $out/$spiralDir

    rm -rf $out/$spiralDir/namespaces
    mkdir $out/$spiralDir/namespaces
    ln -s $spiral/$spiralDir/namespaces/* $out/$spiralDir/namespaces

    rm -rf $out/$spiralDir/namespaces/packages
    mkdir $out/$spiralDir/namespaces/packages
    ln -s $spiral/$spiralDir/namespaces/packages/* $out/$spiralDir/namespaces/packages

    ${
      builtins.concatStringsSep "\n" (
        builtins.attrValues (
          builtins.mapAttrs (pkg: src: ''
            ln -s ${src} $out/$spiralDir/namespaces/packages/${pkg}
          '') spiralPackagesSrc
        )
      )
    }
  ''
