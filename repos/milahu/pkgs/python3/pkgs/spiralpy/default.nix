{ lib
, python3
, fetchFromGitHub
, spiral
, numpy
, cmake
, gnumake
, llvmPackages
#, cupy
#, withCuda ? false
}:

python3.pkgs.buildPythonPackage rec {
  pname = "spiralpy";
  version = "1.0.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "spiral-software";
    repo = "python-package-spiralpy";
    rev = version;
    hash = "sha256-LFHsnn+EOQcD1+LlBFPtk4zewredjHdGB38tsn0aBjc=";
  };

  patchPhase = ''
    substituteInPlace spiralpy/spiral.py \
      --replace-fail \
        "    SPIRAL_EXE = 'spiral'" \
        "$(
          # https://github.com/spiral-software/python-package-spiralpy/issues/4
          # prefer SPIRAL_HOME over PATH
          echo '    SPIRAL_EXE = "spiral"'
          #echo '    SPIRAL_HOME = os.environ.get("SPIRAL_HOME")'
          echo '    SPIRAL_HOME = os.environ.get("SPIRAL_DIR") or os.environ.get("SPIRAL_HOME") or "${spiral}/${spiral.spiralDir}"'
          echo '    if SPIRAL_HOME:'
          echo '        # help spiral to find packages in $SPIRAL_DIR/namespaces/packages/'
          echo '        os.environ["SPIRAL_DIR"] = SPIRAL_HOME'
          echo '        # help spiralpy to find headers in $SPIRAL_HOME/profiler/targets/include/'
          echo '        os.environ["SPIRAL_HOME"] = SPIRAL_HOME'
          echo '        SPIRAL_EXE = os.path.join(SPIRAL_HOME, "bin", "spiral")'
          echo '        assert os.path.exists(SPIRAL_EXE), f"not found {repr(SPIRAL_EXE)}"'
        )" \
      --replace-fail \
        'def isSpiralInPath(progname):' \
        "$(
          # https://github.com/spiral-software/python-package-spiralpy/issues/4
          # simplify isSpiralInPath
          echo 'import shutil'
          echo 'def isSpiralInPath(progname):'
          echo '    return shutil.which(progname) != None'
        )" \

    # fix args for subprocess.run
    substituteInPlace spiralpy/spsolver.py \
      --replace-fail \
        "cmd = 'cmake ' + cmake_defroot" \
        "cmd = os.environ.get('CMAKE_EXE', '${cmake}/bin/cmake') + ' ' + cmake_defroot" \
      --replace-fail \
        "cmd += ' . && cmake --build" \
        "cmd += ' . && ' + os.environ.get('CMAKE_EXE', '${cmake}/bin/cmake') + ' --build" \
      --replace-fail \
        "cmd += ' . && make install'" \
        "cmd += ' . && ' + os.environ.get('MAKE_EXE', '${gnumake}/bin/make') + ' install'" \
      --replace-fail \
        "        runResult = subprocess.run" \
        "$(
          echo "        if not 'CC' in os.environ: os.environ['CC'] = '${llvmPackages.clang}/bin/clang'"
          echo "        if not 'CXX' in os.environ: os.environ['CXX'] = '${llvmPackages.clang}/bin/clang++'"
          echo "        if not 'AS' in os.environ: os.environ['AS'] = '${llvmPackages.clang}/bin/as'"
          echo "        runResult = subprocess.run"
        )" \

  '';

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = [
    spiral
    numpy
    #cupy # TODO withCuda
  ];

  pythonImportsCheck = [ "spiralpy" ];

  meta = with lib; {
    description = "A Python front end to specify high-level numerical computations";
    homepage = "https://github.com/spiral-software/python-package-spiralpy";
    license = licenses.bsd2WithViews;
    maintainers = with maintainers; [ ];
  };
}
