{ lib
, pythonOlder
, buildPythonPackage
, fetchPypi
, h11
, h2
, priority
, toml
, typing-extensions
, wsproto
, pytest
}:

buildPythonPackage rec {
  pname = "hypercorn";
  version = "0.10.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "Hypercorn";
    inherit version;
    sha256 = "sha256-40c+seQYeyRovXHv9Zc3NvyHqb9Jl02gWSXrTr7Vqv8=";
  };

  postPatch = ''
    sed -i -e '/pytest-cov/d' setup.py
  '';

  # does not have pytest-trio yet
  doCheck = false;

  checkInputs = [ pytest ];

  propagatedBuildInputs = [
    h11
    h2
    priority
    toml
    typing-extensions
    wsproto
  ];

  meta = with lib; {
    description = "A ASGI Server based on Hyper libraries and inspired by Gunicorn";
    homepage = https://gitlab.com/pgjones/hypercorn/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
