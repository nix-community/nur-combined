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
  version = "5.4.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "box";
    rev = version;
    sha256 = "sha256-SkteajcWG7rBFMm6Xp6QCfkZfwthRituGL/RtICbtYk=";
  };

  propagatedBuildInputs = [
    msgpack
    ruamel_yaml
    toml
  ];

  checkInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Python dictionaries with advanced dot notation access";
    homepage = "https://github.com/cdgriffith/Box/wiki";
    changelog = "https://github.com/cdgriffith/Box/releases/tag/${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
