{ lib, stdenv, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "morecantile";
  version = "3.1.2";
  disabled = python3Packages.pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = "morecantile";
    rev = version;
    hash = "sha256-QvqXpcjunRWzfdcoyt3pUulDd20Ga8Cs9NTeLnUf5c8=";
  };

  propagatedBuildInputs = with python3Packages; [ attrs pydantic pyproj ];

  checkInputs = with python3Packages; [ mercantile pytestCheckHook ];

  installCheckPhase = "$out/bin/morecantile --version | grep ${version} > /dev/null";

  meta = with lib; {
    description = "Construct and use map tile grids in different projection";
    homepage = "https://developmentseed.org/morecantile/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
