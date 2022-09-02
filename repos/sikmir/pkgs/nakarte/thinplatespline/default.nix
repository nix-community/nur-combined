{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "thinplatespline";
  version = "2013-01-23";

  src = fetchFromGitHub {
    owner = "wladich";
    repo = "thinplatespline";
    rev = "55fecd22c7160577b925e03169e74bd488a41cf3";
    hash = "sha256-t15iO+3UZKnORiQaYoGD4RLZx2SHtCbjg+Qr+sAHQHY=";
  };

  postPatch = ''
    2to3 -n -w tps/*.py
    substituteInPlace tps/__init__.py --replace "_tps" "._tps"
  '';

  doCheck = false;

  pythonImportsCheck = [ "tps" ];

  meta = with lib; {
    description = "Python library for thin plate spline calculations";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
