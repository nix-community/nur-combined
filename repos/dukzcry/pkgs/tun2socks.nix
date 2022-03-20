{ lib, stdenv, buildGo117Module, fetchFromGitHub }:

buildGo117Module rec {
  pname = "tun2socks";
  version = "2.3.2";

  src = fetchFromGitHub {
    owner = "xjasonlyu";
    repo = pname;
    rev = "v${version}";
    sha256 = "1p8hifl30zq80k16240c8ssaab3mi1c4j9i0rirlv6algj8zzd9s";
  };

  vendorSha256 = "1hcv6jlbap7mvz7406li1418bxdj7af7a8csjryikcpnk4jc9hkm";

  meta = with lib; {
    description = "tun2socks - powered by gVisor TCP/IP stack";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
