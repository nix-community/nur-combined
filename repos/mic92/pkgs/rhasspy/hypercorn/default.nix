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
  version = "0.9.5";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "Hypercorn";
    inherit version;
    sha256 = "d94fa535e238ce1cd9c9b5f4cb77cb785d53069a5dc57a017e7c2fc51104ad5e";
  };

  postPatch = ''
    sed -i -e '/pytest-cov/d' setup.py
  '';

  # does not have pytest-trio yet
  doCheck = false;

  checkInputs = [ pytest ];

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # h2 (>=3.1.0)
  # wsproto (>=0.14.0)
  # # Extra packages (may not be necessary)
  # aioquic (<1.0,>=0.8.1) ; extra == 'h3'
  # asynctest ; extra == 'tests'
  # hypothesis ; extra == 'tests'
  # pytest ; extra == 'tests'
  # pytest-asyncio ; extra == 'tests'
  # pytest-cov ; extra == 'tests'
  # pytest-trio ; extra == 'tests'
  # trio ; extra == 'tests'
  # trio (>=0.11.0) ; extra == 'trio'
  # uvloop ; extra == 'uvloop'
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
