{ stdenv, fetchFromGitHub, buildPythonPackage, python-dateutil, docopt, pyyaml }:
buildPythonPackage rec {
  pname = "pykwalify";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "Grokzen";
    repo = "pykwalify";
    rev = version;
    sha256 = "1g2fc47kw7j3rgc4w5dzji1cqv7hp544fbl0a9fy0xkcb2wrf4m5";
  };

  propagatedBuildInputs = [
    python-dateutil
    docopt
    pyyaml
  ];

  checkPhase = "true";

  meta = with stdenv.lib; {
    description = "Python YAML/JSON schema validation library";
    license = licenses.mit;
    homepage = https://github.com/Grokzen/pykwalify;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
