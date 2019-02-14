{ lib, pythonPackages, fetchFromGitHub, beets }:

pythonPackages.buildPythonApplication rec {
  name = "beets-alternatives-${version}";
  version = "0.9.0";

  src = fetchFromGitHub {
    repo = "beets-alternatives";
    owner = "geigerzaehler";
    rev = "v${version}";
    sha256 = "19160gwg5j6asy8mc21g2kf87mx4zs9x2gbk8q4r6330z4kpl5pm";
  };

  nativeBuildInputs = [ beets pythonPackages.nose ];

  checkPhase = "nosetests";

  meta = with lib; {
    description = "Beets plugin to manage external files";
    homepage = https://github.com/geigerzaehler/beets-alternatives;
    maintainers = with maintainers; [ aszlig ];
    license = with licenses; mit;
  };
}
