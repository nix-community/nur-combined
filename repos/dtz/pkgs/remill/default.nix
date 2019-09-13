{ stdenv, fetchFromGitHub, buildEnv,
cmake,
llvm,
python2Packages,
protobuf,
intelxed,
glog,
google-gflags,
gtest,
doInstallCheck ? false,
}:

with stdenv.lib;
let
  llvm_version = getVersion llvm;
  srcinfo = {
    version = "2019-03-23";
    src = fetchFromGitHub {
      owner = "trailofbits";
      repo = "remill";
      rev = "1f94663462d4e9bfd2edd6654aeee26624ce72f1";
      sha256 = "1yjanzq7yxks912ipj17gn4l7f1kkh798nvfljrali9kpcbffkll";
    };
  };
  mcsema_srcinfo = import ./mcsema.nix { inherit fetchFromGitHub; };

  meta = {
    description = "Library for lifting of x86, amd64, and aarch64 machine code to LLVM bitcode, plus mcsema";
    license = licenses.asl20;
    homepage = https://github.com/trailofbits/remill;
    maintainers = with maintainers; [ dtzWill ];
  };

  python-protobuf = python2Packages.protobuf.override { inherit protobuf; };
  python = python2Packages.python;

  remill-bins = with srcinfo; stdenv.mkDerivation rec {
    name = "remill-bins-${version}";
    inherit version src;

    enableParallelBuilding = true;
    hardeningDisable = [ "all" ];

    postUnpack = ''
      unpackFile ${mcsema_srcinfo.src}
      chmod u+rw -R mcsema-* remill-*
      mv mcsema-* $sourceRoot/tools/mcsema
    '';

    postPatch = ''
      for x in CMakeLists.txt tools/mcsema/CMakeLists.txt; do
        substituteInPlace $x \
          --replace "find_package(XED REQUIRED)" ""
      done
      for x in tests/{AArch64,X86}/CMakeLists.txt; do
        substituteInPlace $x \
          --replace "find_package(gtest REQUIRED)" \
                    "find_package(GTest REQUIRED)" \
          --replace "gtest_LIBRARIES" "GTEST_LIBRARY"
      done

      # This keeps the chrpath command, don't do that for now
      # sed -i CMakeLists.txt -e 's|\(.*\)COMMAND ''${CHRPATH_COMMAND}|\1COMMAND chmod u+w ''${output_file_path}\n\0|'

      # This drops the chrpath command (comments it out)
      # since their invocation doesn't accomodate existing rpath value
      sed -i CMakeLists.txt -e 's|\(.*\)COMMAND ''${CHRPATH_COMMAND}|\1COMMAND chmod u+w ''${output_file_path}\n# \0|'

      sed -i -e '/CODE/,+5d' tools/mcsema/CMakeLists.txt

      # Don't look for "ABI" includes under 'x86_64-linux-gnu', they're not there
      # No "ultrasound" header, not sure what that's about.
      # xlocale is non-standard and not in glibc 2.27+, it should be 'locale.h'
      substituteInPlace tools/mcsema/mcsema/OS/Linux/ABI_libc.h \
        --replace "#include <x86_64-linux-gnu/" \
                  "#include <" \
        --replace "#include <sys/ultrasound.h>"  "" \
        --replace '<xlocale.h>' '<locale.h>'

      # Don't try to build ABI library using the wrong list of headers/functions, just use what's there I suppose.
      substituteInPlace tools/mcsema/CMakeLists.txt \
        --replace 'add_subdirectory(mcsema/OS/Linux)' ""

      substituteInPlace cmake/settings.cmake --replace "/usr/local" "$out"
    '';

    preConfigure = ''
      export LLVM_DIR=${llvm}
    '';

    cmakeFlags = [
      "-DXED_INCLUDE_DIRS=${intelxed}/include"
      "-DXED_LIBRARIES=${intelxed}/lib/libxed.so;${intelxed}/lib/libxed-ild.so"
    ];

    postInstall = ''
      chmod +rx $out/bin/*

      mkdir -p $out/gen
      mv ../tools/mcsema/tools/mcsema_disass/{ida,binja} $out/gen/
    '';

    nativeBuildInputs = [ cmake ];
    buildInputs = [
      llvm
      python python-protobuf protobuf
      intelxed
      glog google-gflags gtest
    ];

    inherit doInstallCheck;

    installCheckPhase = ''
      make build_x86_tests
      make test
    '';

    passthru = { inherit mcsema_srcinfo; };

    inherit meta;
  };

  remill-mcsema-py = with mcsema_srcinfo; python2Packages.buildPythonApplication rec {
    name = "remill-mcsema-py-${version}";
    inherit src version;

    preConfigure = ''
      cp -r ${remill-bins}/gen/* tools/mcsema_disass/

      sed -i 's,import itertools,import itertools\nimport site\nsite.addsitedir("${python-protobuf}/lib/${python.libPrefix}/site-packages")\nsite.addsitedir("${python2Packages.python_magic}/lib/${python.libPrefix}/site-packages")\nsite.addsitedir("${python2Packages.six}/lib/${python.libPrefix}/site-packages"),' tools/mcsema_disass/ida{,7}/get_cfg.py
      cd tools
    '';

    propagatedBuildInputs = [ python-protobuf python2Packages.python_magic python2Packages.six ];

    inherit meta;
  };
in
  # Merge things together into unified 'mcsema':
  (buildEnv {
    name = "remill-${srcinfo.version}";
    paths = [ remill-bins remill-mcsema-py ];
  }) // srcinfo
  // { bins = remill-bins; py = remill-mcsema-py; } # kludge to make these accessible via 'projects.mcsema.bins' and similar
