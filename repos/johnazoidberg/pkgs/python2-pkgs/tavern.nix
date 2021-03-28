{ stdenv, lib, fetchFromGitHub, buildPythonPackage, pyyaml, pykwalify, requests
, pyjwt, python-box , future, contextlib2, stevedore
, backports_functools_lru_cache, paho-mqtt , jmespath, pytest, }:
buildPythonPackage rec {
  pname = "tavern";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "taverntesting";
    repo = "tavern";
    rev = version;
    sha256 = "1pjz94bb8sbipn1j69hf2yxf2ypppbvfim35rsajrfjqp424lb3x";
  };

  propagatedBuildInputs = [
    pyyaml
    pykwalify#>=1.6.1
    requests
    pyjwt
    python-box
    future
    contextlib2
    stevedore
    backports_functools_lru_cache
    paho-mqtt#==1.3.1
    jmespath
    pytest#>=3.6.0,<5
  ];

  checkPhase = "true";

  meta = with lib; {
    description = "Command-line tool and Python library and Pytest plugin for automated testing of RESTful APIs";
    license = licenses.mit;
    homepage = https://github.com/taverntesting/tavern;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}
