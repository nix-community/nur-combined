{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, msgpack
, ruamel_yaml
, toml
  # test inputs
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "python-box";
  version = "5.2.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "box";
    rev = version;
    sha256 = "0mkksdpgkihqshb115fxz0s7g79422hghj0n2ji3g63j9b7qa0wi";
  };

  propagatedBuildInputs = [
    msgpack
    ruamel_yaml
    toml
  ];

  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook ];
  # TODO: remove when I drop nixpkgs 20.03; these error on msgpack 0.6.3
  disabledTests = lib.optionals (lib.versionOlder msgpack.version "1.0.0") [
    "test_msgpack_strings"
    "test_msgpack_files"
  ];

  meta = with lib; {
    description = "Python dictionaries with advanced dot notation access";
    homepage = "https://github.com/cdgriffith/Box/wiki";
    changelog = "https://github.com/cdgriffith/Box/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
