{ lib, pkgs, fetchFromGitHub, python3Packages, poetry, zeromq, procset, pybatsim, remote_pdb}:

python3Packages.buildPythonPackage rec {
  name = "oar-${version}";
  version = "3.0.0.dev4";
  format = "pyproject";
  #disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
        owner = "oar-team";
        repo = "oar3";
        rev = "031a80749ad778fa52d80437c180c90f33e67fb1";
        sha256 = "sha256-bCkiVizmjVaGOtMu/NYkYblCGu00i5tEjw64b6dEFmk=";
  };


  nativeBuildInputs = [ poetry ];

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
      # simpy
      # redis
      # pytest_flask
      psycopg2
      # remote_pdb # for debug only
      passlib
      escapism
      toml
      fastapi
      uvicorn
    python-multipart
   ];

  doCheck = false;
  #doCheck = true;
  postInstall = ''
    cp -r setup $out
    cp -r oar/tools $out
    cp -r visualization_interfaces $out
  '';

  meta = {
    broken = true;
    homepage = "https://github.com/oar-team/oar3";
    description = "The OAR Resources and Tasks Management System";
    license = lib.licenses.lgpl3;
    longDescription = "";
  };
}
