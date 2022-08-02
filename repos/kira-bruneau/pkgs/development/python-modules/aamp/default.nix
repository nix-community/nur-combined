{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, pyyaml
}:

buildPythonPackage rec {
  pname = "aamp";
  version = "1.4.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-cmn2THRhGWebqNPakMT25Lahzwm822DKMYh5Kgn7Pmw=";
  };

  patches = [
    ./relax-requirements.patch
  ];

  propagatedBuildInputs = [
    pyyaml
  ];

  checkPhase = ''
    runHook preCheck
    PATH=$out/bin:$PATH python test.py
    runHook postCheck
  '';

  pythonImportsCheck = [ "aamp" ];

  meta = with lib; {
    description = "Nintendo parameter archive (AAMP) library and converters";
    homepage = "https://github.com/zeldamods/aamp";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kira-bruneau ];
  };
}
