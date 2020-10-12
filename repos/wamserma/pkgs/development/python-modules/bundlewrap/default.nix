{ lib
, fetchFromGitHub
, buildPythonPackage
, cryptography
, jinja2
, Mako
, passlib
, pytest
, pyyaml
, requests
, setuptools
, six
}:

buildPythonPackage rec {
  pname = "bundlewrap";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "bundlewrap";
    repo = "bundlewrap";
    rev = "${version}";
    sha256 = "0hi57k59hfbva8jbljwmld7r1g2qa96sk7c0b1c39dm6j5sx1dfi";
  };

  propagatedBuildInputs = [
    cryptography jinja2 Mako passlib pyyaml requests setuptools six
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
