{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  isPy3k,
  isPyPy,
  python,
  pythonAtLeast,
}:

let
  testDir = if isPy3k then "src" else "python2";

in
buildPythonPackage (finalAttrs: {
  pname = "typing";
  version = "3.10.0.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-E7StIR9U3b+T5ZAamWex4HcgwdG3jVlqxqQ5ZBqhsTA=";
  };

  disabled = pythonAtLeast "3.5";

  # Error for Python3.6: ImportError: cannot import name 'ann_module'
  # See https://github.com/python/typing/pull/280
  # Also, don't bother on PyPy: AssertionError: TypeError not raised
  doCheck = pythonOlder "3.6" && !isPyPy;

  checkPhase = ''
    cd ${testDir}
    ${python.interpreter} -m unittest discover
  '';

  meta = with lib; {
    description = "Backport of typing module to Python versions older than 3.5";
    homepage = "https://docs.python.org/3/library/typing.html";
    license = licenses.psfl;
  };
})
