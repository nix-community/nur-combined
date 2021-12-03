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
, librouteros
}:

buildPythonPackage rec {
  pname = "bundlewrap";
  version = "4.13.4";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "bundlewrap";
    repo = "bundlewrap";
    rev = "${version}";
    sha256 = "0i63q5cxgaq1czc2qdgm66byxa4fxk6k85lc1m5j9ykxq5fqpm84";
  };

  propagatedBuildInputs = [
    cryptography jinja2 Mako passlib pyyaml requests setuptools tomlkit librouteros
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
