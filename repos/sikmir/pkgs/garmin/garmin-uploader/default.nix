{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "garmin-uploader";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "La0";
    repo = "garmin-uploader";
    rev = version;
    hash = "sha256-OHY4f+0jfxKXiwRJRdSarlb2H+lEt2EVoAAsD4aEc9o=";
  };

  propagatedBuildInputs = with python3Packages; [ requests six ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "Garmin Connect Python Uploader";
    inherit (src.meta) homepage;
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
  };
}
