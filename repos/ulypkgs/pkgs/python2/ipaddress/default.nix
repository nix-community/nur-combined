{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonAtLeast,
  python,
}:

if (pythonAtLeast "3.3") then
  null
else
  buildPythonPackage (finalAttrs: {
    pname = "ipaddress";
    version = "1.0.23";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-t/jgNpWAu0ok1bodfMKWYKSmmHdj+vHYqARoMOAg5+I=";
    };

    checkPhase = ''
      ${python.interpreter} test_ipaddress.py
    '';

    meta = with lib; {
      description = "Port of the 3.3+ ipaddress module to 2.6, 2.7, and 3.2";
      homepage = "https://github.com/phihag/ipaddress";
      license = licenses.psfl;
    };

  })
