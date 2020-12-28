{ pkgs, lib, fetchFromGitHub, python3Packages }:

with python3Packages;

let
  # officially supported database drivers
  dbDrivers = [
    psycopg2
    # sqlite driver is already shipped with python by default
  ];

in
buildPythonPackage rec {
  pname = "matrix-registration";
  version = "1.0.0.dev3";
  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "ZerataX";
    repo = pname;
    rev = "v${version}";
    sha256 = "0dz60qv32dn0ci4c696c12rlqamd00m19rn8c6dxbza23r7a952n";
  };

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
  '';

  propagatedBuildInputs = [
    appdirs
    flask
    flask-babel
    flask-cors
    flask-httpauth
    flask-limiter
    flask_sqlalchemy
    python-dateutil
    pyyaml
    requests
    waitress
    wtforms
  ] ++ dbDrivers;

  checkInputs = [
    flake8
    parameterized
  ];

  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `matrix-registration`
  # in its environment to create a database schema from all models.
  #
  # Hence we need to patch away `alembic` from `matrix-registration` and create an `alembic`
  # which has `matrix-registration` in its environment.
  passthru.alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ dbDrivers ++ [
      pkgs.matrix-registration
    ];
  });

  meta = with lib; {
    homepage = https://github.com/ZerataX/matrix-registration/;
    description = "a token based matrix registration api";
    # license = licenses.mit;
    # maintainers = with maintainers; [ zeratax ];
  };
}
