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
  version = "0.13.1";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    pname = "Quart";
    inherit version;
    sha256 = "sha256-nGNOTB5LIbgkADxnbeFYNYEljHKwrE0rp0fbhG6X/1Y=";
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
    (werkzeug.overrideAttrs (old: rec {
      version = "1.0.1";
      src = old.src.override {
        inherit version;
        sha256 = "0z74sa1xw5h20yin9faj0vvdbq713cgbj84klc72jr9nmpjv303c";
      };
    }))
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
