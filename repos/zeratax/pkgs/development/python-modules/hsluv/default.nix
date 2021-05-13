{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "hsluv";
  version = "5.0.2";

  src = fetchPypi {
    inherit version pname;
    extension = "tar.gz";
    sha256 = "ffea98b29c6a7d25a4296eed400b491c89fd89365806a0f646ede44c043727fa";
  };

  meta = with lib; {
    description = "A Python implementation of HSLuv.";
    homepage = "https://www.hsluv.org/";
    license = licenses.mit;
  };
}
