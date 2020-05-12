{ stdenv, buildPythonPackage, fetchFromGitHub
, substituteAll, gdb
, colorama, django, flask, psutil, pytest
, pytest-timeout, pytest_xdist, requests
, isPy38 ? null
}:

buildPythonPackage rec {
  pname = "ptvsd";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = pname;
    rev = "v${version}";
    sha256 = "1cm5pcs7vb73fmaldnmdyyn4zkcr0ixs1hmmi1g7b5y4kgyh7jxq";
  };

  patches = [
    # Hard code GDB path (used to attach to process) & fix dlopen call
    (substituteAll {
      src = ./fix-add-code-to-python-process.patch;
      inherit gdb;
    })

    # Extend instead of replace PYTHONPATH in tests
    ./fix-test-pythonpath.patch
  ];

  # Remove pre-compiled "attach" libraries and recompile for host platform
  preBuild = ''(
    cd src/ptvsd/_vendored/pydevd/pydevd_attach_to_process

    rm attach_linux_amd64.so attach_linux_x86.so
    rm attach_x86_64.dylib attach_x86.dylib
    rm attach_amd64.dll attach_amd64.pdb attach_x86.dll attach_x86.pdb

    $CXX linux_and_mac/attach.cpp -Ilinux_and_mac -fPIC -nostartfiles ${{
      "x86_64-linux" = "-shared -m64 -o attach_linux_amd64.so";
      "i686-linux" = "-shared -m32 -o attach_linux_x86.so";
      "x86_64-darwin" = "-dynamiclib -std=c++11 -D_REENTRANT -lc -arch x86_64 -o attach_x86_64.dylib";
      "i686-darwin" = "-dynamiclib -std=c++11 -D_REENTRANT -lc -arch i386 -o attach_x86.dylib";
    }.${stdenv.hostPlatform.system}}
  )'';

  checkInputs = [
    colorama django flask psutil pytest
    pytest-timeout pytest_xdist requests
  ];

  # Override default arguments in pytest.ini
  checkPhase = "pytest -v --timeout 0 -n $NIX_BUILD_CORES";

  meta = with stdenv.lib; {
    homepage = "https://github.com/microsoft/ptvsd";
    description = "Python debugger package for use with Visual Studio and Visual Studio Code";
    license = licenses.mit;
    maintainers = with maintainers; [ metadark ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "i686-darwin" ];

    # pydevd_cython.c fails to compile with: error: too many arguments to function ‘PyCode_New’
    # See https://github.com/cython/cython/issues/2938
    broken = if isPy38 != null then isPy38 else false;
  };
}
