{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {
  pname = "hev-socks5-tproxy";
  version = "2.4.0";
  src = fetchFromGitHub ({
    owner = "heiher";
    repo = "hev-socks5-tproxy";
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-aV/UBGOi4021PKPt2PJNe6mmYUJc0sd2cSn2vOOFslw=";
  });

  installFlags = [ "INSTDIR=${placeholder "out"}" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "A simple, lightweight socks5 transparent proxy for Linux. (IPv4/IPv6/TCP/UDP)";
    homepage = "https://github.com/heiher/hev-socks5-tproxy";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
