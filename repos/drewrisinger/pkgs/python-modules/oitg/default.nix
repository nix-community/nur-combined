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
  version = "unstable-2019-12-18";

  src = fetchFromGitHub {
    owner = "OxfordIonTrapGroup";
    repo = "oitg";
    rev = "644d0311c75b0624c4eebfc9d227c5b067ff3d0e";
    sha256 = "1prcirxir043prb6w9ydn14kfjgnhd13ksnx0df4lm790rbqf04q";
  };

  propagatedBuildInputs = [
    h5py
    numpy
    scipy
    statsmodels
  ];

  pythonCheckImports = [ "oitg" "oitg.fit" ];

  checkInputs = [ pytestCheckHook ];
  dontUseSetuptoolsCheck = true;

  # Remove tests from $out directory to avoid conflicts.
  postCheck = ''
    rm -rf $out/${python.sitePackages}/test
  '';

  meta = with lib; {
    description = "Python package of helper routines (result loading, fitting, etc.) for the Oxford Ion-Trap Group";
    homepage = "https://oxfordiontrapgroup.github.io/oitg/";
    downloadPage = "https://github.com/OxfordIonTrapGroup/oitg";
    license = licenses.unfree;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
