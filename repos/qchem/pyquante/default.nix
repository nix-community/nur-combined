{ lib, fetchurl, buildPythonPackage
, numpy, isPy37
} :

buildPythonPackage rec {
  pname = "pyquante";
  version = "1.6.5";
  disabled = isPy37;

  src = fetchurl {
    url = "mirror://sourceforge/project/pyquante/PyQuante-1.6/PyQuante-${version}/PyQuante-${version}.tar.gz";
    sha256 = "1k5prp7y1b94a6s88s1xwm83m973gnda6qmjw7whqz1wa29c2nhl";
  };

  propagatedBuildInputs = [ numpy ];

  doCheck = true;

  checkPhase = ''
    python Tests/runalltests.py
  '';

  meta = with lib; {
    description = "Open-source suite of programs for developing quantum chemistry methods";
    homepage = "http://pyquante.sourceforge.net/";
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
  };
}
