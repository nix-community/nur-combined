{ stdenv, buildPythonPackage, fetchFromGitHub
, substituteAll, gdb
, autoPatchelfHook
, colorama, django_2_2, flask, psutil, pytest
, pytest-timeout, pytest_xdist, requests
}:

buildPythonPackage rec {
  pname = "ptvsd";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "Microsoft";
    repo = "ptvsd";
    rev = "v${version}";
    sha256 = "1cm5pcs7vb73fmaldnmdyyn4zkcr0ixs1hmmi1g7b5y4kgyh7jxq";
  };

  patches = [
    # Hard code GDB path. Used to attach to processes.
    (substituteAll {
      src = ./fix-add-code-to-python-process.patch;
      inherit gdb;
    })

    ./fix-test-pythonpath.patch
  ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    # libstdc++ required by attach_linux_amd64.so
    stdenv.cc.cc
  ];

  checkInputs = [
    colorama django_2_2 flask psutil pytest
    pytest-timeout pytest_xdist requests
  ];

  # Override default arguments in pytest.ini
  checkPhase = "pytest -v --timeout 0 -n $NIX_BUILD_CORES";

  meta = with stdenv.lib; {
    homepage = "https://github.com/microsoft/ptvsd";
    description = "Python debugger package for use with Visual Studio and Visual Studio Code";
    license = licenses.mit;
    maintainers = [ maintainers.metadark ];
  };
}
