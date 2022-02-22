{ lib
, stdenv
, buildPythonPackage
, rustPlatform
, fetchFromGitHub
, libiconv
  # Check inputs
, pytestCheckHook
, fixtures
, graphviz
, matplotlib
, networkx
, numpy
, pillow
, pydot
, testtools
}:

buildPythonPackage rec {
  pname = "retworkx";
  version = "0.11.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "retworkx";
    rev = version;
    sha256 = "sha256-o3XPMTaiFH5cBtyqtW650wiDBElLvCmERr2XwwdPO1c=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      sha256 = "sha256-Zhk4m+HNtimhPWfiBLi9dqJ0fp2D8d0u9k6ROG0/jBo=";
  };

  nativeBuildInputs = with rustPlatform; [ cargoSetupHook maturinBuildHook ];

  buildInputs = lib.optionals stdenv.isDarwin [ libiconv ];

  pythonImportsCheck = [ "retworkx" ];
  checkInputs = [
    pytestCheckHook
    fixtures
    graphviz
    matplotlib
    numpy
    networkx
    pillow
    pydot
  ];
  preCheck = ''
    export TESTDIR=$(mktemp -d)
    cp -r tests/ $TESTDIR
    pushd $TESTDIR
  '';
  postCheck = "popd";
  disabledTests = lib.optionals (lib.versionOlder testtools.version "2.5.0") [ "test_gnp_random" ];

  meta = with lib; {
    description = "A python graph library implemented in Rust.";
    homepage = "https://retworkx.readthedocs.io/en/latest/index.html";
    downloadPage = "https://github.com/Qiskit/retworkx/releases";
    changelog = "https://github.com/Qiskit/retworkx/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
