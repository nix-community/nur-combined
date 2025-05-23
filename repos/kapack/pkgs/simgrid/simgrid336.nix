{ stdenv, lib, fetchFromGitLab, cmake, perl, python3, boost
, fortranSupport ? false, gfortran
, buildDocumentation ? false, fig2dev, ghostscript, doxygen
, buildJavaBindings ? false, openjdk
, buildPythonBindings ? false, python3Packages
, modelCheckingSupport ? true, libunwind, libevent, elfutils # Inside elfutils: libelf and libdw
, bmfSupport ? true, eigen
, minimalBindings ? false
, debug ? false
, optimize ? (!debug)
, moreTests ? false
, withoutBin ? false
, withoutBoostPropagation ? false
}:

with lib;

let
  optionOnOff = option: if option then "on" else "off";
  isAArch64 = lib.hasPrefix "aarch64" stdenv.hostPlatform.system;
  isDarwin = lib.hasInfix "darwin" stdenv.hostPlatform.system;
in

stdenv.mkDerivation rec {
  pname = "simgrid";
  version = "3.36";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-7w4ObbMem1Y8Lh9MOcdCSEktTDRkvVKmKlS9adm15oE=";
  };

  propagatedBuildInputs = optionals (!withoutBoostPropagation) [ boost ];
  nativeBuildInputs = [ cmake perl python3 ]
    ++ optionals withoutBoostPropagation [ boost ]
    ++ optionals fortranSupport [ gfortran ]
    ++ optionals buildJavaBindings [ openjdk ]
    ++ optionals buildPythonBindings [ python3Packages.pybind11 ]
    ++ optionals buildDocumentation [ fig2dev ghostscript doxygen ]
    ++ optionals bmfSupport [ eigen ]
    ++ optionals modelCheckingSupport [ libunwind libevent elfutils ];

  outputs = [ "out" ]
    ++ optionals buildPythonBindings [ "python" ];

  # "Release" does not work. non-debug mode is Debug compiled with optimization
  cmakeBuildType = "Debug";
  cmakeFlags = [
    "-Denable_documentation=${optionOnOff buildDocumentation}"
    "-Denable_java=${optionOnOff buildJavaBindings}"
    "-Denable_python=${optionOnOff buildPythonBindings}"
    "-DSIMGRID_PYTHON_LIBDIR=./" # prevents CMake to install in ${python3} dir
    "-Denable_msg=${optionOnOff buildJavaBindings}"
    "-Denable_fortran=${optionOnOff fortranSupport}"
    "-Denable_model-checking=${optionOnOff modelCheckingSupport}"
    "-Denable_ns3=off"
    "-Denable_lua=off"
    "-Denable_lib_in_jar=off"
    "-Denable_maintainer_mode=off"
    "-Denable_mallocators=on"
    "-Denable_debug=on"
    "-Denable_smpi=on"
    "-Dminimal-bindings=${optionOnOff minimalBindings}"
    "-Denable_smpi_ISP_testsuite=${optionOnOff moreTests}"
    "-Denable_smpi_MPICH3_testsuite=${optionOnOff moreTests}"
    "-Denable_compile_warnings=off"
    "-Denable_compile_optimizations=${optionOnOff optimize}"
    "-Denable_lto=${optionOnOff optimize}"
  ];
  makeFlags = optional debug "VERBOSE=1";

  # needed to run tests and to ensure correct shabangs in output scripts
  preBuild = ''
    patchShebangs ..
  '';

  # needed by tests (so libsimgrid.so is found)
  preConfigure = ''
    export LD_LIBRARY_PATH="$PWD/build/lib"
  '';

  doCheck = !(isAArch64 || isDarwin); # YOLO
  preCheck = ''
    # prevent the execution of tests known to fail
    cat <<EOW >CTestCustom.cmake
    SET(CTEST_CUSTOM_TESTS_IGNORE smpi-replay-multiple)
    EOW

    # make sure tests are built in parallel (this can be long otherwise)
    make tests -j $NIX_BUILD_CORES
  '';

  postInstall = lib.optionalString withoutBin ''
    # remove bin from output if requested.
    # having a specific bin output would be cleaner but it does not work currently (circular references)
    rm -rf $out/bin
    rm -f $out/lib/simgrid/smpimain
    rm -f $out/lib/simgrid/smpireplaymain
  '' + lib.optionalString buildPythonBindings ''
    # manually install the python binding if requested.
    mkdir -p $python/lib/python${lib.versions.majorMinor python3.version}/site-packages/
    cp ./lib/simgrid.cpython*.so $python/lib/python${lib.versions.majorMinor python3.version}/site-packages/
   '';

  # improve debuggability if requested
  hardeningDisable = lib.optionals debug [ "fortify" ];
  dontStrip = debug;

  meta = {
    description = "Framework for the simulation of distributed applications";
    longDescription = ''
      SimGrid is a toolkit that provides core functionalities for the
      simulation of distributed applications in heterogeneous distributed
      environments.  The specific goal of the project is to facilitate
      research in the area of distributed and parallel application
      scheduling on distributed computing platforms ranging from simple
      network of workstations to Computational Grids.
    '';
    homepage = "https://simgrid.org/";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ mickours mpoquet ];
    platforms = platforms.all;
  };
}
