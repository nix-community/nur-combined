{ buildPythonPackage
, lib
, fetchPypi
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "colorzero";
  version = "2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-59WlwmzQ3DexZOvvxgnziN4k+Fk7ZZGR4S2F+PnV61g=";
  };

  propagatedBuildInputs = [];

  doCheck = false;
  checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "colorzero" ];

  meta = with lib; {
    description = "Yet another python color library";
    homepage = "https://colorzero.readthedocs.io/en/latest/";
    license = licenses.bsd3;
    maintainers = [ maintainers.drewrisinger ];
  };
}
