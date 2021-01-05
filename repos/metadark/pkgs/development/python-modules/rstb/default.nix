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
    sha256 = "066k8d16x8ary7g5hj7sxx8sw3lhims3n4nkakys1afhwr3s9py1";
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
