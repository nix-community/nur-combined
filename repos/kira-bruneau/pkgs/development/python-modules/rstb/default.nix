{ lib
, buildPythonPackage
, fetchFromGitHub
, substituteAll
, oead
}:

buildPythonPackage rec {
  pname = "rstb";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-wd+kR+bQqaD9VNMSO3SNkA6uUe/6SFje8VmhbkJD0xg=";
  };

  patches = [
    # Use nixpkgs version instead of versioneer
    (substituteAll {
      src = ./hardcode-version.patch;
      inherit version;
    })
  ];

  propagatedBuildInputs = [
    oead
  ];

  pythonImportsCheck = [ "rstb" ];

  meta = with lib; {
    description = "Breath of the Wild RSTB parser and editing tool";
    homepage = "https://github.com/zeldamods/rstb";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = true; # oead references commit outside of branch
  };
}
