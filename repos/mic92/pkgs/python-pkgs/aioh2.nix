{ stdenv, fetchPypi, buildPythonPackage
, h2, isPy3k, priority
}:
buildPythonPackage rec {
  pname = "aioh2";
  version = "0.2.2";

  disabled = !isPy3k;

  src = fetchPypi {
    inherit pname version;
    sha256 = "03i24wzpw0mrnrpck3w6qy83iigwl7n99sdrndqzxfyrc69b99wd";
  };

  propagatedBuildInputs = [ h2 priority ];
  meta = with stdenv.lib; {
    description = "HTTP/2 implementation with hyper-h2 on Python 3 asyncio.";
    homepage = https://github.com/decentfox/aioh2;
    license = licenses.bsd3;
  };
}
