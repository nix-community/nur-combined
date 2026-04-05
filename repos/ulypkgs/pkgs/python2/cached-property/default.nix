{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  freezegun,
}:

buildPythonPackage rec {
  pname = "cached-property";
  version = "1.5.1";

  # conftest.py is missing in PyPI tarball
  src = fetchFromGitHub {
    owner = "pydanny";
    repo = pname;
    rev = version;
    sha256 = "0xh0pwmiikx0il9nnfyf034ydmlw6992s0d209agd9j5d3s2k5q6";
  };

  checkInputs = [ freezegun ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    "test_threads_ttl_expiry"
  ];
  doCheck = false; # not sure why the `disabledTests` attr does not work

  meta = {
    description = "A decorator for caching properties in classes";
    homepage = "https://github.com/pydanny/cached-property";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ ericsagnes ];
  };
}
