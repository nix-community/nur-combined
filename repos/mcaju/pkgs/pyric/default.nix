{ stdenv
, lib
, buildPythonPackage
, fetchFromGitHub
}:

buildPythonPackage rec {
  pname = "pyric";
  version = "0.1.6-17-g0562b17";

  src = fetchFromGitHub {
    owner = "wraith-wireless";
    repo = pname;
    rev = "0562b1770acd2904d98535f6fe0f9b20f5d4088d";
    sha256 = "031gls3bdyvd22k4xkigc86afzf22wk8jdyjic2jvq0wzaw7dhkg";
  };

  patches = [
    ./rfkill.patch
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python wireless library for Linux";
    homepage = "http://wraith-wireless.github.io/PyRIC";
    license = licenses.gpl3;
  };
}
