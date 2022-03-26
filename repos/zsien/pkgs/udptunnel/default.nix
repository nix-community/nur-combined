{ lib, stdenv, fetchurl, libnsl }:

stdenv.mkDerivation rec {
  pname = "udptunnel";
  version = "1.1";
  src = fetchurl {
    url    = "http://www1.cs.columbia.edu/~lennox/udptunnel/udptunnel-${version}.tar.gz";
    sha256 = "0w26flhj8bhjz9kp4vsfzv8ldir2fvfbnvh76ibwanvk8lhf3h25";
  };
  buildInputs = [ libnsl ];

  meta = with lib; {
    description = "tunnel UDP packets over a TCP connection";
    longDescription = ''
      UDPTunnel is a small program which can tunnel UDP packets bi-directionally over a TCP connection.
      Its primary purpose (and original motivation) is to allow multi-media conferences to traverse a firewall
      which allows only outgoing TCP connections. UDPTunnel also can be used for security tests in networks. 
    '';
    homepage = "http://www1.cs.columbia.edu/~lennox/udptunnel/";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
