{ stdenv, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "chump";
  version = "1.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1vjm68ax2r355gaq3ggxal0f7wah6p2vx5wvjcpf6scwhhwryrgl";
  };

  meta = with stdenv.lib; {
    description = "A fully featured API wrapper for Pushover.";
    homepage = "https://github.com/karanlyons/chump";
    license = licenses.asl20;
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.unix;
  };
}
