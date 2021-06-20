{ lib, pkgs, fetchFromGitHub, python3Packages, zeromq, procset, pybatsim, remote_pdb}:

python3Packages.buildPythonPackage rec {
  name = "oar-${version}";
  version = "3.0.0.dev4";
  src = fetchFromGitHub {
        owner = "oar-team";
        repo = "oar3";
        rev = "8eb57ab83144c64de3bd9c4b024380a78311279d";
        sha256 = "sha256-PnPUq+KUTqG0TU0lQSeVrftimoJuz1VOG2eqsfXNUzs=";
  };
  #src = /home/auguste/dev/oar3;

propagatedBuildInputs = with python3Packages; [
    pyzmq
    requests
    alembic
    procset
    click
    simplejson
    flask
    tabulate
    psutil
    sqlalchemy-utils
    simpy
    redis
    #pybatsim
    #pytest_flask
    psycopg2
    #remote_pdb # for debug only
    passlib
    pyyaml
    escapism
    toml
  ];

  doCheck = false;

  postInstall = ''
    cp -r setup $out
    cp -r oar/tools $out
    cp -r visualization_interfaces $out
  '';

  meta = {
    #broken = true;
    homepage = "https://github.com/oar-team/oar3";
    description = "The OAR Resources and Tasks Management System";
    license = lib.licenses.lgpl3;
    longDescription = "";
  };
}
