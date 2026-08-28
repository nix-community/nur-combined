{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  coverage,
}:

buildPythonPackage (finalAttrs: {
  version = "1.3.7";
  pname = "nose";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-8b/++cvIJij259e0DX4lWu+qGttqGx0mxpqLeeYgipg=";
  };

  propagatedBuildInputs = [ coverage ];

  doCheck = false; # lot's of transient errors, too much hassle
  checkPhase =
    if python.is_py3k or false then
      ''
        ${python}/bin/${python.executable} setup.py build_tests
      ''
    else
      ""
      + ''
        rm functional_tests/test_multiprocessing/test_concurrent_shared.py* # see https://github.com/nose-devs/nose/commit/226bc671c73643887b36b8467b34ad485c2df062
        ${python}/bin/${python.executable} selftest.py
      '';

  meta = with lib; {
    description = "A unittest-based testing framework for python that makes writing and running tests easier";
    homepage = "http://readthedocs.org/docs/nose/";
    license = licenses.lgpl3;
  };

})
