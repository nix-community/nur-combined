{ lib
, stdenv
, fetchFromGitHub
, cmake
, xtensor
, enablePython ? false
, python3Packages
, catch2_3
}:

stdenv.mkDerivation rec {
  pname = "cppcolormap";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "tdegeus";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-YVVWeR7K1t3uOzCFes2zu+c0I1Tb1S1wh/Rmzi60Dp0=";
  };

  nativeBuildInputs = [
    cmake
  ] ++ lib.optionals enablePython [
    python3Packages.python
  ];

  buildInputs = [
    xtensor
    catch2_3
  ] ++ lib.optionals enablePython [
    python3Packages.pybind11
  ];

  propagatedBuildInputs = with python3Packages; lib.optionals enablePython [
    numpy
    (xtensor-python.overridePythonAttrs (_: {
      format = "other";
    }))
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=ON"
  ] ++ lib.optionals enablePython [
    "-DBUILD_PYTHON=ON"
  ];

  doCheck = true;

  SETUPTOOLS_SCM_PRETEND_VERSION = version;

  meta = with lib; {
    description = "Library with colormaps for C++";
    homepage = "https://github.com/tdegeus/cppcolormap";
    platforms = lib.platforms.unix;
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
  };
}
