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
}:

buildPythonPackage rec {
  pname = "bundlewrap";
  version = "4.2.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "bundlewrap";
    repo = "bundlewrap";
    rev = "${version}";
    sha256 = "1p52w1sg1s2j7fmj34lw5m3axw44ww29ndgck8qfzh5wsldd0rlr";
  };

  propagatedBuildInputs = [
    cryptography jinja2 Mako passlib pyyaml requests setuptools tomlkit
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
