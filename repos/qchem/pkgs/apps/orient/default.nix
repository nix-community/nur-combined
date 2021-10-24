{ stdenv, lib, fetchgit, writeTextFile, git, gfortran, blas, lapack,
  xorg, python3, libGL, libGLU, freeglut
}:

let
  pythonWP = python3.withPackages (p: with p; [
    numpy
  ]);

  # Not inlined with a cat EOF, as the string interpolation with ''${} is
  # handled differently.
  makeInclude = writeTextFile {
    name = "Flags";
    text = ''
      FC        := gfortran
      FFLAGS    := ''$(DEBUG) -DF2003

      LIBRARIES := -L${blas}/lib
      LIBS      := -llapack -lblas

      X11LIBDIR := -L${xorg.libX11}/lib
      X11LIB    := -lX11 -lm

      ifeq "''${OPENGL}" "yes"
        OGLLIBDIR := -L${libGL}/lib -L${libGLU}/lib -L${freeglut}/lib
        OGLLIB    := -lglut -lGL -lGLU
        FFLAGS    := ''${FFLAGS} -DOPENGL
      endif

      LDFLAGS   := ''$(DEBUG)
      LIBRARIES := ''${OGLLIBDIR} ''${X11LIBDIR} ''${LIBRARIES}
      LIBS      := ''${LIBS} -lpthread -lgfortran -lc ''${OGLLIB} ''${X11LIB}

      MOD       := mod
    '';
  };

in stdenv.mkDerivation rec {
  pname = "orient";
  version = "5.0.10";

  # The build system requires the git directory to be present.
  # Therefore don't use fetchFromGitlab, but fetchgit, which allows
  # to keep the git directory.
  src = fetchgit {
    url = "https://gitlab.com/anthonyjs/${pname}.git";
    rev = "e31e41e907d6b680a9cef2c97238b59d649f565a";
    sha256 = "Fupi/6Yrp+tM2YVgjGMmuYKI200NMeFUbzcomKvVDCA=";
    leaveDotGit = true;
  };

  nativeBuildInputs = [
    gfortran
    git
  ];

  buildInputs = [
    blas
    lapack
    libGL
    libGLU
    freeglut
    xorg.libX11
  ];

  propagatedBuildInputs = [ pythonWP ];

  patches = [ ./MakePrefix.patch ];

  postPatch = ''
    patchShebangs .

    # Write a custom Makefile for Gfortran/Nix
    rm ./x86-64/gfortran/Flags
    cp ${makeInclude} ./x86-64/gfortran/Flags
  '';

  makeFlags = [ "COMPILER=gfortran" "OPENGL=yes" ];

  meta = with lib; {
    description = "Program for carrying out calculations of various kinds for an assembly of interacting molecules";
    homepage = "https://gitlab.com/anthonyjs/orient";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ maintainers.sheepforce ];
  };
}
