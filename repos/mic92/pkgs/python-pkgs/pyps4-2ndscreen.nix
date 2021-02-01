{ lib
, buildPythonPackage
, fetchFromGitHub
, construct
, pycryptodomex
, aiohttp
, click
, pytestCheckHook
, asynctest
, pytest-asyncio
, pythonOlder
}:

buildPythonPackage rec {
  pname = "pypys4-2ndscreen";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "ktnrg45";
    repo = "pyps4-2ndscreen";
    rev = version;
    sha256 = "1gyv9c7n2jwckb5l0ghplrd4081nhbqbymvihjlc2srqq9y2wj03";
  };

  propagatedBuildInputs = [
    construct
    pycryptodomex
    aiohttp
    click
  ];

  doCheck = pythonOlder "3.8";

  checkInputs = [
    asynctest
    pytest-asyncio
    pytestCheckHook
  ];

  # don't work in sandbox because of network permissions
  checkPhase = ''
    py.test -k "not test_no_status and not test_parse_errors and not test_login and not test_get_ps_store_data"
  '';

  meta = with lib; {
    description = "Python Library for controlling a Sony PlayStation 4 Console";
    homepage = "https://github.com/ktnrg45/pyps4-2ndscreen";
    license = licenses.gpl3;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
