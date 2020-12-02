{ lib
, buildPythonPackage
, fetchPypi
, click
, psutil
}:

buildPythonPackage rec {
  pname = "daemonocle";
  version = "1.0.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "025fb5c53b42618f8cdd592936621c833a871f27eb747e0fdbf3cdb4643a92b3";
  };

  propagatedBuildInputs = [ click psutil ];

  # Tests don't seem to work with sandboxing enabled.
  doCheck = false;

  meta = with lib; {
    description = "A Python library for creating super fancy Unix daemons";
    longDescription = ''
      daemonocle is a library for creating your own Unix-style daemons
      written in Python.  It solves many problems that other daemon
      libraries have and provides some really useful features you don't
      often see in other daemons.
    '';
    homepage = "https://github.com/jnrbsn/daemonocle";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ AluisioASG ];
  };
}
