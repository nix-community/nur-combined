{ lib
, stdenv
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, colorama
, numpy
, oead
}:

buildPythonPackage {
  pname = "botw-havok";
  version = "0.3.18";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "krenyy";
    repo = "botw_havok";
    rev = "dc7966c7780ef8c8a35e061cd3aacc20020fa2d7";
    sha256 = "sha256-eUbs8Ip/2S1cGQbmL0D5d1uTAF9TvnAzIxQE2tdnltI=";
  };

  patches = [
    ./relax-requirements.patch
  ];

  propagatedBuildInputs = [
    colorama
    numpy
    oead
  ];

  # No tests
  doCheck = false;
  pythonImportsCheck = [ "botw_havok" ];

  meta = with lib; {
    description = "A library for manipulating Breath of the Wild Havok packfiles";
    homepage = "https://github.com/krenyy/botw_havok";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ kira-bruneau ];
    broken = stdenv.isDarwin; # oead cmake --build fails with exit code 2 on darwin
  };
}
