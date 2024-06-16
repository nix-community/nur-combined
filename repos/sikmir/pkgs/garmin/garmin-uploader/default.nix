{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "garmin-uploader";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "La0";
    repo = "garmin-uploader";
    rev = version;
    hash = "sha256-OHY4f+0jfxKXiwRJRdSarlb2H+lEt2EVoAAsD4aEc9o=";
  };

  dependencies = with python3Packages; [
    requests
    six
  ];

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = {
    description = "Garmin Connect Python Uploader";
    homepage = "https://github.com/La0/garmin-uploader";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
