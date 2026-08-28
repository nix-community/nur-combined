{
  lib,
  python,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage (finalAttrs: {
  pname = "scandir";
  version = "1.10.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-TUYx9gYuZY6QB6sxSam5FPNUjLOL+wIcZPOaAlzleK4=";
  };

  doCheck = false;

  checkPhase = "${python.interpreter} test/run_tests.py";

  meta = with lib; {
    description = "A better directory iterator and faster os.walk()";
    homepage = "https://github.com/benhoyt/scandir";
    license = licenses.gpl3;
    maintainers = with maintainers; [ abbradar ];
  };
})
