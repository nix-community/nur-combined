{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "morecantile";
  version = "3.0.0";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = pname;
    rev = version;
    hash = "sha256-k4EfOYXXyOmcWs6pi/7Muk8X1ncIyoo6R1LWfuobpWQ=";
  };

  propagatedBuildInputs = with python3Packages; [ pydantic pyproj ];

  checkInputs = with python3Packages; [ mercantile pytestCheckHook ];

  installCheckPhase = "$out/bin/morecantile --version";

  meta = with lib; {
    description = "Construct and use map tile grids in different projection";
    homepage = "https://developmentseed.org/morecantile/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
