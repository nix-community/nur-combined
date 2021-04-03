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
  version = "3.8.0";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = pname;
    rev = "v${version}";
    sha256 = "1xhmrqyih2yddfgzq37vixp03ifqd7d6s9y81szmw282lmy7aalg";
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
