{ fetchFromGitHub, buildPythonPackage, backports_functools_lru_cache, selenium, regex, ... }:
buildPythonPackage rec {
  pname = "indic_transliteration";
  version = "unstable-2020-12-15";
  src = fetchFromGitHub {
    repo = pname;
    owner = "sanskrit-coders";
    rev = "2ea25a03af15937916b6768835e056166986c567";
    sha256 = "1pcf800hl0zkcffc47mkjq9mizsxdi0hwxlnij5bvbqdshd3w9ll";
  };
  patches = [ ./regex-version.patch ];
  propagatedBuildInputs = [ backports_functools_lru_cache selenium regex ];
  doCheck = false;
}
