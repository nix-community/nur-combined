{ lib
, buildPythonPackage
, fetchPypi
, aiosmtpd
, cryptography
, python-dotenv
, pytestCheckHook
, pytest-asyncio
}:

buildPythonPackage rec {
  pname = "smtpdfix";
  version = "0.3.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Nf1IYVMVGA9d7s8Fs4aUBUNer+wdZBYJL0Q9RJxG7s0=";
  };

  propagatedBuildInputs = [
    aiosmtpd
    cryptography
    python-dotenv
  ];

  checkInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  disabledTests = [
    # Contains odd 8025 == 5025 assertions that always fail
    "test_init_envfile"
    "test_config_file"
  ];

  pythonImportsCheck = [ "smtpdfix" ];

  meta = with lib; {
    description = "A SMTP server for use as a pytest fixture that implements encryption and authentication.";
    homepage = "https://github.com/bebleo/smtpdfix";
    license = licenses.mit;
    maintainers = with maintainers; [ imsofi ];
  };
}
