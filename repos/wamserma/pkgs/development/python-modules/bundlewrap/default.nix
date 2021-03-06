{ lib
, fetchFromGitHub
, buildPythonPackage
, pythonOlder
, cryptography
, jinja2
, Mako
, passlib
, pytest
, pyyaml
, requests
, setuptools
, tomlkit
, pyrouteros
}:

buildPythonPackage rec {
  pname = "bundlewrap";
  version = "4.10.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "bundlewrap";
    repo = "bundlewrap";
    rev = "${version}";
    sha256 = "sha256-d7rEvDj0iHCLhnm8936Yu35bPyJNTsJHZHXijzTIPyw=";
  };

  propagatedBuildInputs = [
    cryptography jinja2 Mako passlib pyyaml requests setuptools tomlkit pyrouteros
  ];

  checkInputs = [ pytest ];

  checkPhase = ''
    # only unit tests as integration tests need a OpenSSH client/server setup
    py.test tests/unit
  '';

  meta = with lib; {
    homepage = "https://bundlewrap.org/";
    description = "Easy, Concise and Decentralized Config management with Python";
    license = [ licenses.gpl3 ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
