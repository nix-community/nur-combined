{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
  # Python Inputs
# , addict
, cycler
, descartes
, docutils
, gdspy
, geopandas
, ipython
, jedi
, matplotlib
, numpy
, pandas
, pint
, pyEPR-quantum
, pygments
, pyqode-python
, pyqode-qt
, pyside2
, scipy
, shapely
  # Check Inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "qiskit-metal";
  version = "0.0.3";
  format = "setuptools";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "Qiskit";
    repo = "qiskit-metal";
    rev = version;
    sha256 = "0kaa1pc4fi90xasr1c32j71363j1pipmrl0vgd0cy5ijf1vkm4x0";
  };

  propagatedBuildInputs = [
    # addict
    cycler
    descartes
    docutils
    gdspy
    geopandas
    ipython
    jedi
    matplotlib
    numpy
    pandas
    pint
    pyEPR-quantum
    pygments
    pyqode-python
    pyqode-qt
    pyside2
    scipy
    shapely
  ];

  checkInputs = [ pytestCheckHook ];

  pythonImportsCheck = [
    "qiskit_metal"
  ];

  meta = with lib; {
    description = "Quantum Hardware Design";
    longDescription = "Open-source project for engineers and scientists to design superconducting quantum devices with ease.";
    homepage = "https://qiskit.org";
    downloadPage = "https://github.com/qiskit/qiskit-metal";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
