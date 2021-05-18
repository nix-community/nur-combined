{ lib, fetchFromGitHub, python3Packages, mercantile, rasterio }:

python3Packages.buildPythonPackage rec {
  pname = "morecantile";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "developmentseed";
    repo = pname;
    rev = version;
    hash = "sha256-JX8wwR1I7+6qQq4OBJakQZx/uVkyJeaTjDZPWZeD+7I=";
  };

  propagatedBuildInputs = with python3Packages; [ pydantic rasterio ];

  checkInputs = with python3Packages; [ mercantile pytestCheckHook ];

  installCheckPhase = "$out/bin/morecantile --version";

  meta = with lib; {
    description = "Construct and use map tile grids in different projection";
    homepage = "https://developmentseed.org/morecantile/";
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
