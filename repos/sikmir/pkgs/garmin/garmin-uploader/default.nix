{ lib, fetchFromGitHub, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "garmin-uploader";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "La0";
    repo = "garmin-uploader";
    rev = version;
    sha256 = "1nkkhj30yb00l0an3ds4x4gzcmmfkba4aj84ifbi4zr3xmzkhxiq";
  };

  propagatedBuildInputs = with python3Packages; [ requests six ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  doCheck = false;

  meta = with lib; {
    description = "Garmin Connect Python Uploader";
    homepage = "https://github.com/La0/garmin-uploader";
    license = licenses.gpl2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
