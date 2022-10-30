{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "pyrobuf";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "appnexus";
    repo = "pyrobuf";
    rev = "811a9325eed1c0070ceb424020fe81eeef317e0c";
    hash = "sha256-7NEzRM9B/9f5ODNzDKws7t/9gqbJK7T9AuET+pT26P0=";
  };

  nativeBuildInputs = with python3Packages; [ cython pytest-runner ];

  propagatedBuildInputs = with python3Packages; [ jinja2 ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "A Cython based protobuf compiler";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
  };
}
