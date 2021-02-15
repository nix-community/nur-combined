{ lib
, buildPythonPackage
, fetchFromGitHub
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

  postPatch = ''
    # Use nixpkgs version instead of versioneer
    substituteInPlace setup.py \
      --replace "version=versioneer.get_version()" "version='${version}'" \
      --replace "cmdclass=versioneer.get_cmdclass()," ""
  '';

  propagatedBuildInputs = [
    oead
  ];

  meta = with lib; {
    description = "Breath of the Wild RSTB parser and editing tool";
    homepage = "https://github.com/zeldamods/rstb";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
