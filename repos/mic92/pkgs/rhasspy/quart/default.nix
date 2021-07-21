{ lib
, buildPythonPackage
, pythonOlder
, fetchPypi
, aiofiles
, blinker
, click
, hypercorn
, itsdangerous
, jinja2
, toml
, werkzeug
, pytest
, hypothesis
, pytest-asyncio
, asynctest
}:

buildPythonPackage rec {
  pname = "quart";
  version = "0.14.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "Quart";
    inherit version;
    sha256 = "sha256-QpxbT/J+HS+coKrMOParoP9Js4uBVEi/JLYT094S6gI=";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # # Extra packages (may not be necessary)
  # python-dotenv ; extra == 'dotenv'
  propagatedBuildInputs = [
    aiofiles
    blinker
    click
    hypercorn
    itsdangerous
    jinja2
    toml
    werkzeug
  ];

  # asynctest is broken for newer python's
  doCheck = pythonOlder "3.8";

  checkInputs = [
    pytest
    hypothesis
    pytest-asyncio
    asynctest
  ];

  meta = with lib; {
    description = "A Python ASGI web microframework with the same API as Flask";
    homepage = https://gitlab.com/pgjones/quart/;
    license = licenses.mit;
  };
}
