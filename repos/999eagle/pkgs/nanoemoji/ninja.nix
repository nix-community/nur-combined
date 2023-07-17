{
  python3,
  fetchFromGitHub,
  fetchurl,
  cmake,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "ninja";
  version = "1.11.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "scikit-build";
    repo = "ninja-python-distributions";
    rev = version;
    hash = "sha256-scCYsSEyN+u3qZhNhWYqHpJCl+JVJJbKz+T34gOXGJM=";
  };

  # see NinjaUrls.cmake
  ninja_src = fetchurl {
    url = "https://github.com/Kitware/ninja/archive/v1.11.1.g95dee.kitware.jobserver-1.tar.gz";
    sha256 = "7ba84551f5b315b4270dc7c51adef5dff83a2154a3665a6c9744245c122dd0db";
  };
  postUnpack = ''
    mkdir -p "$sourceRoot/Ninja-src"
    pushd "$sourceRoot/Ninja-src"
    tar -xavf ${ninja_src} --strip-components 1
    popd
  '';

  dontUseCmakeConfigure = true;

  patches = [
    # make sure cmake doesn't try to download the ninja sources
    ./ninja-no-download.patch
  ];

  nativeBuildInputs = with python3.pkgs; [
    setuptools-scm
    scikit-build
    cmake
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
    pytest
    pytest-cov
    pytest-runner
    pytest-virtualenv
    codecov
    coverage
  ];
}
