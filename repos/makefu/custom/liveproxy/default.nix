{ lib
, buildPythonPackage
, fetchPypi
, streamlink
}:

buildPythonPackage rec {
  pname = "liveproxy";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "70ba2f7b57cdf19c6d971a434ed47cccb5fdfe4621baa76a3f6221e75b7f2729";
  };

  # # Package conditions to handle
  # # might have to sed setup.py and egg.info in patchPhase
  # # sed -i "s/<package>.../<package>/"
  # streamlink (>=1.1.1)
  propagatedBuildInputs = [
    streamlink
  ];

  meta = with lib; {
    description = "LiveProxy is a local Proxyserver between Streamlink and an URL";
    homepage = https://github.com/back-to/liveproxy;
    license = lib.licenses.bsd2;
    # maintainers = [ maintainers. ];
  };
}
