{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, ninja
, setuptools
, aws-sdk-cpp
, pybind11
, requests
, torch
, urllib3
, wheel
}:

buildPythonPackage rec {
  pname = "torchdata";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pytorch";
    repo = "data";
    rev = "v${version}";
    hash = "sha256-7TCmTYUhi3rH+bF7Ht5Sj470iFMOMpAZ7NV0o5/uLkQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace \
        'subprocess.check_call(["git", "submodule"' \
        '# subprocess.check_call(["git", "submodule"' \
      --replace \
        'sys.exit(1)' \
        'pass'
  '';

  nativeBuildInputs = [
    cmake
    ninja
    setuptools
    wheel
  ];

  buildInputs = [
    aws-sdk-cpp
    pybind11
  ];

  propagatedBuildInputs = [
    requests
    urllib3
    torch # FIXME: upstream puts it in native deps
  ];

  cmakeFlags = [
    "-GNinja"
    "-DUSE_SYSTEM_PYBIND11=ON"
    "-DUSE_SYSTEM_AWS_SDK_CPP=ON"
  ];

  postConfigure = ''
    cd ..
  '';

  pythonImportsCheck = [ "torchdata" ];

  meta = with lib; {
    description = "A PyTorch repo for data loading and utilities to be shared by the PyTorch domain libraries";
    homepage = "https://github.com/pytorch/data";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
