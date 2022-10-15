{ lib
, stdenv
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, substituteAll
, cmake
}:

buildPythonPackage rec {
  pname = "oead";
  version = "1.2.4-2";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = "oead";
    rev = "refs/tags/v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-MQyE1fAZ1IMC1yIVcMgtha3vxgYVz4fLItL7MLCT5tw=";
  };

  patches = [
    # Use nixpkgs version instead of versioneer
    (substituteAll {
      src = ./hardcode-version.patch;
      inherit version;
    })
  ];

  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;
  pythonImportsCheck = [ "oead" ];

  meta = with lib; {
    description = "Library for recent Nintendo EAD formats in first-party games";
    homepage = "https://github.com/zeldamods/oead";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = stdenv.isDarwin; # cmake --build fails with exit code 2 on darwin
  };
}
