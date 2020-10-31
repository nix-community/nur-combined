{ lib
, buildPythonPackage
, fetchFromGitHub
, oead
}:

buildPythonPackage rec {
  pname = "rstb";
  version = "unstable-2020-06-21";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = pname;
    # Use commit that replaces syaz0 dependency with oead
    rev = "a0888edade48fcfe13ef0a4c1667fe76c5a13635";
    sha256 = "17yzcwwpl5hpq6hc6whvfha8q3igqcckfkasmv0q2zjayng2j6hr";
  };

  postPatch = ''
    # Use nixpkgs version instead of versioneer
    substituteInPlace setup.py \
      --replace "version=versioneer.get_version()" "version='1.2.1'" \
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
