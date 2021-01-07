{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
, pybind11
, numpy
, scipy
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "qdldl";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "oxfordcontrol";
    repo = "qdldl-python";
    rev = "v${version}";
    sha256 = "07h5mcdlzzvhhdarxs97zkv765yig5hqfvvprsdjdbfrzrm1nlz8";
    fetchSubmodules = true;
  };

  dontUseCmakeConfigure = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [ pybind11 ];

  propagatedBuildInputs = [
    numpy
    scipy
  ];

  pythonImportsCheck = [ "qdldl" ];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;
  # for nixos-20.03
  preCheck = "pushd $TMP/$sourceRoot";
  postCheck = "popd";

  meta = with lib; {
    description = "A free LDL factorization routine";
    homepage = "https://github.com/oxfordcontrol/qdldl";
    downloadPage = "https://github.com/oxfordcontrol/qdldl-python";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
