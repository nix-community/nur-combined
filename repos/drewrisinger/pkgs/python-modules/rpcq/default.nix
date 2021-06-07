{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, msgpack
, python-rapidjson
, pyzmq
, ruamel_yaml
  # Check Inputs
, pytestCheckHook
, numpy
, pytest-asyncio
, pytestcov
}:

buildPythonPackage rec {
  pname = "rpcq";
  version = "3.9.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-8ZTV+sboOdiJjjEBXPjpD9oGWI0gCJ9QqcEreSo8Suc=";
  };

  propagatedBuildInputs = [
    msgpack
    python-rapidjson
    pyzmq
    ruamel_yaml
  ];

  postPatch = ''
    substituteInPlace setup.py --replace "msgpack>=0.6,<1.0" "msgpack"
  '';

  dontUseSetuptoolsCheck = true;
  checkInputs = [
    pytestCheckHook
    numpy
    pytest-asyncio
    pytestcov
  ];

  meta = with lib; {
    description = "A library for quantum programming using Quil.";
    homepage = "https://docs.rigetti.com/en/";
    license = licenses.asl20;
    maintainers = with maintainers; [ drewrisinger ];
  };
}
