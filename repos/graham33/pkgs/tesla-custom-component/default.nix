{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, poetry-core
, teslajsonpy
}:

buildPythonPackage rec {
  pname = "tesla-custom-component";
  version = "1.4.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "alandtse";
    repo = "tesla";
    rev = "v${version}";
    sha256 = "1nl9ghasy222n9mkm0q7glljfbsfa2y6kvbfq5260zfsiw3n1ik2";
  };

  patches = [ ./poetry.patch ];

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    teslajsonpy
  ];

  meta = with lib; {
    homepage = "https://github.com/alandtse/tesla";
    license = licenses.asl20;
    description = "A fork of the official Tesla integration in Home Assistant.";
    maintainers = with maintainers; [ graham33 ];
  };
}
