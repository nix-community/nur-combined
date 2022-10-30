{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "thinplatespline";
  version = "2022-06-02";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "thinplatespline";
    rev = "acedd7aa9eef7f66a54df53a9596a0b4d95af92b";
    hash = "sha256-/RLcB+xq1U7AKx26brw4gG29AMJB1LedC+5MNbK/rxI=";
  };

  doCheck = false;

  pythonImportsCheck = [ "tps" ];

  meta = with lib; {
    description = "Python library for thin plate spline calculations";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
