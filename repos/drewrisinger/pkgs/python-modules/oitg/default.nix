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
  version = "unstable-2020-11-02";

  src = fetchFromGitHub {
    owner = "OxfordIonTrapGroup";
    repo = "oitg";
    rev = "718ea5bf7dca4e8ff3c60271cac052df818274fa";
    sha256 = "1zs5w5fb10xshzqa0gkngpq174jw7s4rls8j5l3dnvgxicl850z8";
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
