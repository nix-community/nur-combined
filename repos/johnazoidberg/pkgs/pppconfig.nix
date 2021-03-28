# FIXME: Doesn't really work on NixOS because it want's to write in /etc
{ stdenv, lib, fetchurl, ppp, dialog, perl }:
stdenv.mkDerivation rec {
  name = "pppconfig-${version}";
  version = "2.3.23";

  src = fetchurl {
    url = "http://httpredir.debian.org/debian/pool/main/p/pppconfig/pppconfig_${version}.tar.gz";
    sha256 = "07y44lwlipqcaav6aqywgw2bmfg39zdgiwdyxfzw2m48vi3wj0km";
  };

  buildPhase = "true";

  buildInputs = [ ppp dialog perl ];
  
  installPhase = ''
    install -D -m755 pppconfig $out/bin/pppconfig
    install -D -m755 0dns-up $out/bin/0dns-up
    install -D -m755 0dns-down $out/bin/0dns-down
    install -D -m644 man/pppconfig.8 $out/share/man/man8/pppconfig.8

    install -dm755 $out/etc/ppp/{peers,resolv} $out/etc/chatscripts
    install -Dm644 COPYING $out/share/licenses/pppconfig/COPYING.txt 
  '';

  patchPhase = ''
    substituteInPlace "pppconfig" --replace "$etc = \"/etc\";" "$etc = \"/home/zoid/etc\"";
  '';

  meta = with lib; {
    description = "Configure pppd to connect to the Internet";
    license = licenses.gpl2;
    homepage = http://ftp.debian.org/debian/pool/main/p/pppconfig/;
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
}

