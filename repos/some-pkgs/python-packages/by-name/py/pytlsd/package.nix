{ lib
, build
, buildPythonPackage
, cmake
, config
, cudaPackages
, cudaSupport ? config.cudaSupport
, fetchFromGitHub
, ninja
, numpy
, opencv4
, pillow
, pybind11
, pytestCheckHook
, scikit-build
, scikit-image
, scipy
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "pytlsd";
  version = "0.0.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "iago-suarez";
    repo = "pytlsd";
    rev = "v${version}";
    hash = "sha256-zEjhUe7RwMhDXeAWZxW1pdmxU7six0adorX0U5vC5xA=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'add_subdirectory(pybind11)' 'find_package(pybind11 REQUIRED)' \
      --replace 'find_package(opencv QUIET)' 'find_package(opencv REQUIRED)'

    sed -i \
      -e 's|ext_dir =.*$|ext_dir = Path("build/")|' \
      -e 's|build_temp =.*$|build_temp = Path("build/")|' \
      setup.py
  '';

  # Cd back from cmake's build/
  postConfigure = ''
    cd ..
  '';

  cmakeFlags = [
    "-GNinja"
  ];

  nativeBuildInputs = [
    build
    cmake
    ninja
    pybind11
    setuptools
    wheel
  ] ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
  ];

  propagatedBuildInputs = [
    numpy
    opencv4
    pillow
    scikit-build
    scikit-image
    scipy
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  pytestFlagsArray = [
    "tests/tests.py"
  ];

  pythonImportsCheck = [ "pytlsd" ];

  meta = with lib; {
    description = "Python transparent bindings for LSD (Line Segment Detector";
    homepage = "https://github.com/iago-suarez/pytlsd";
    license = licenses.mit;
    maintainers = with maintainers; [ SomeoneSerge ];
  };
}
