{ lib
, fetchFromGitHub
, buildPythonPackage
, setuptools
, wheel
}:

buildPythonPackage rec {
  pname = "gnumake-tokenpool";
  version = "0.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "milahu";
    repo = "gnumake-tokenpool";
    rev = "py/${version}";
    hash = "sha256-HFrCHY3BbMIO6lDrOe4WMRYNBmbC8jzcOX/g2+cJYf0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [ "gnumake_tokenpool" ];

  meta = with lib; {
    description = "Jobclient and jobserver for the GNU make tokenpool protocol";
    homepage = "https://github.com/milahu/gnumake-tokenpool";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
