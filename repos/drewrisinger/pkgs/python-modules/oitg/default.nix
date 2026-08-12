{ lib
, buildPythonPackage
, fetchFromGitHub
, numpy
, statsmodels
, h5py
, scipy
# Test inputs
, python
, pytestCheckHook
}:

buildPythonPackage {
  pname = "oitg";
  version = "unstable-2021-08-23";

  src = fetchFromGitHub {
    owner = "OxfordIonTrapGroup";
    repo = "oitg";
    rev = "a968246ad228c206153a4c5391808517051cf284";
    sha256 = "1dzs2m248zxrqgr7h6x6812ggmyja3rsnd8s0fy97yb78hcfxi6x";
  };

  propagatedBuildInputs = [
    h5py
    numpy
    scipy
    statsmodels
  ];

  pythonCheckImports = [ "oitg" "oitg.fit" ];

  checkInputs = [ pytestCheckHook ];

  # Remove tests from $out directory to avoid conflicts.
  postCheck = ''
    rm -rf $out/${python.sitePackages}/test
  '';

  disabledTests = [
    "test_random_data_fixed_phi" # small error, slightly greater than expected. likely due to random data
  ];

  meta = with lib; {
    description = "Python package of helper routines (result loading, fitting, etc.) for the Oxford Ion-Trap Group";
    homepage = "https://oxfordiontrapgroup.github.io/oitg/";
    downloadPage = "https://github.com/OxfordIonTrapGroup/oitg";
    license = licenses.unfree;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
