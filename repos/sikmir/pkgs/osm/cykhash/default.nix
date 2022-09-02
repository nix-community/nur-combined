{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "cykhash";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "realead";
    repo = "cykhash";
    rev = "v${version}";
    hash = "sha256-Bw85RJudoGNa2GrEwxGaln93T7c2YyRakWZcMJAJwUU=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

  checkInputs = with python3Packages; [ numpy pytestCheckHook ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  pytestFlagsArray = [ "tests/unit_tests" ];

  meta = with lib; {
    description = "cython wrapper for khash";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
