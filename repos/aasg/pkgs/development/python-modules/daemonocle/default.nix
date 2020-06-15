{ lib
, buildPythonPackage
, fetchPypi
, click
, psutil
}:

buildPythonPackage rec {
  pname = "daemonocle";
  version = "1.0.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "a8fc48d55f6390302a9a1816ad488cba640e70948f750d4c8fe5a401294dab68";
  };

  propagatedBuildInputs = [ click psutil ];

  # Tests don't seem to work with sandboxing enabled.
  doCheck = false;

  meta = with lib; {
    description = "A Python library for creating super fancy Unix daemons";
    homepage = "https://github.com/jnrbsn/daemonocle";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.AluisioASG ];
  };
}
