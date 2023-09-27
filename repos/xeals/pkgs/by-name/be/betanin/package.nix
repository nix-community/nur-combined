{ lib
, callPackage
, fetchFromGitHub
, python3
, beets
}:

let
  py = python3.pkgs;

  version = "0.4.0.ffe45c02";

  src = fetchFromGitHub {
    owner = "xeals";
    repo = "betanin";
    rev = "ffe45c028037fc1659f62a9cdc9e1413dc2f358d";
    hash = "sha256-5d8Y7PDlhkdVRVX+KvpiQ2WYNRELwc+ya5s4Qi+YQpI=";
  };

  client = callPackage ./client {
    inherit src version;
  };
in
py.buildPythonApplication {
  pname = "betanin";
  inherit version src;

  clientDistDir = "${client}/lib/node_modules/betanin/dist/";

  doCheck = false;

  patches = [ ./paths.patch ];
  postPatch = ''
    export libPrefix="${python3.libPrefix}"
    substituteAllInPlace betanin/paths.py
  '';

  propagatedBuildInputs =
    (builtins.attrValues {
      inherit (py)
        apprise
        alembic
        click
        flask
        flask-cors
        flask-jwt-extended
        flask_migrate
        flask-restx
        flask-socketio
        flask-sqlalchemy
        gevent
        pyxdg
        loguru
        ptyprocess
        python-engineio
        python-socketio
        sqlalchemy
        sqlalchemy-utils
        toml;
    }) ++ [
      beets
    ];

  meta = {
    homepage = "https://github.com/sentriz/betanin";
    description = "beets based mitm of your torrent client and music player";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = python3.meta.platforms;
  };
}
