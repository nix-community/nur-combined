{ stdenv, pkgs, fetchgit, fetchFromGitHub, python37Packages, zeromq, procset, sqlalchemy_utils, pybatsim,  pytest_flask, remote_pdb}:

python37Packages.buildPythonPackage rec {
  name = "oar-${version}";
  version = "3.0.0.dev3";  

  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "oar3";
    rev = "6b3c2466ea5e4de3dfb621165e52f7e91bb5f30d";
    sha256 = "0cj1k7rwxca25iv6fl7nnarpvk2a2iwr3krq62qrg76vhy4dk5ms";
  };
  #src = /home/auguste/dev/oar3;

  propagatedBuildInputs = with python37Packages; [
    pyzmq
    requests
    sqlalchemy
    alembic
    procset
    click
    simplejson
    flask
    tabulate
    psutil
    sqlalchemy_utils
    simpy
    redis
    pybatsim
    pytest_flask
    psycopg2
    remote_pdb
  ];

  # Tests do not pass
  doCheck = false;

  postInstall = ''
    cp -r setup $out
    cp -r oar/tools $out
    cp -r visualization_interfaces $out
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/oar-team/oar3";
    description = "The OAR Resources and Tasks Management System";
    license = licenses.lgpl3;
    longDescription = ''
    '';
  };
}
