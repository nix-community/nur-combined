{ lib
, buildPythonPackage
, fetchPypi

, bluepy
, pygatt
}:

buildPythonPackage rec {
  pname = "btlewrap";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    extension = "tar.gz";
    sha256 = "f3befbeed3a6c5abf99dc0d6bbaab570868a5175e52252d53c45bd78c85cc294";
  };

  propagatedBuildInputs =
    [ bluepy pygatt ];

  meta = with lib; {
    description = "Wrapper around different bluetooth low energy backends";
    homepage = "https://github.com/ChristianKuehnel/btlewrap";
    license = licenses.mit;
  };

}
