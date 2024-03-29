{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonPackage rec {
  pname = "cykhash";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "realead";
    repo = "cykhash";
    rev = "99db6d2075b1f33177ed034e0c873d58190658ae";
    hash = "sha256-R6a19oExRVHSnfeEM5XsD77BPEWpC0BeNdep12YffN8=";
  };

  nativeBuildInputs = with python3Packages; [ cython ];

  nativeCheckInputs = with python3Packages; [ numpy pytestCheckHook ];

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
