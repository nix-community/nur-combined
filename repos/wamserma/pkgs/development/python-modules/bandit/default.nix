{ lib
, fetchPypi
, buildPythonPackage
, GitPython
, pyyaml
, stevedore
, colorama
, setuptools
, six
# test requirements
#,coverage
#,fixtures
#,hacking
#,mock
#,stestr
#,testscenarios
#,testtools
#,beautifulsoup4
#,pylint
}:

buildPythonPackage rec {
  pname = "bandit";
  version = "1.6.2";

  # pbr builds require a fetchPypi
  #src = fetchFromGitHub {
  #  owner = "PyCQA";
  #  repo = "bandit";
  #  rev = "${version}";
  #  sha256 = "1iibg15ylr4ysyd38by1pjmjisxbgpascbkff81g8dm3331p91z1";
  #};

  src = fetchPypi {
    inherit pname version;
    sha256 = "41e75315853507aa145d62a78a2a6c5e3240fe14ee7c601459d0df9418196065";
  };

  propagatedBuildInputs = [
    GitPython pyyaml stevedore colorama setuptools six
  ];

 # checkInputs = [ coverage fixtures hacking mock stestr testscenarios testtools beautifulsoup4 pylint ];
 # because hacking and stestr have circular deps and also require an acient version of flake8 and
 # require a bunch of unpackaged dependencies
 doCheck = false; 
 
  meta = with lib; {
    homepage = "https://bandit.readthedocs.io/";
    description = "A tool designed to find common security issues in Python code";
    license = [ licenses.asl20 ] ;
    maintainers = with maintainers; [ wamserma ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
