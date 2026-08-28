{
  lib,
  buildPythonPackage,
  fetchPypi,
  unittestCheckHook,
  six,
  stdenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "more-itertools";
  version = "5.0.0";
  format = "setuptools";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-OKk2wKbZiji8wtA/2q7aup9BKHlGHdLO/403Vk1lIuQ=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  propagatedBuildInputs = [ six ];

  # iterable = range(10 ** 10)  # Is efficiently reversible
  # OverflowError: Python int too large to convert to C long
  doCheck = !stdenv.hostPlatform.is32bit;

  meta = {
    homepage = "https://more-itertools.readthedocs.org";
    description = "Expansion of the itertools module";
    license = lib.licenses.mit;
  };
})
