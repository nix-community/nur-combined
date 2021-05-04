{ stdenv
, lib
, buildPythonApplication
, fetchFromGitHub
, pytestCheckHook
, dnsmasq
, iptables
, libnl
, openssl
, pbkdf2
, pyric
, roguehostapd
, scapy
}:

buildPythonApplication rec {
  pname = "wifiphisher";
  version = "1.4-144-g4e1052f";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "4e1052f7e06da1ad66846c41df2be54452a2777b";
    sha256 = "0i6dyvqh881jp679y5sh01mmfb691yslqsmxbkv7lwwsq8kg4hj9";
  };

  patchPhase = ''
    substituteInPlace setup.py \
      --replace /usr/sbin/dnsmasq ${dnsmasq}/bin/dnsmasq \
      --replace '/usr/include/libnl3' '${libnl.dev}/include/libnl3' \
      --replace '/usr/include/openssl' '${openssl.dev}/include' \
      --replace "shutil.rmtree('tmp')" 'pass'
  '';

  checkInputs = [
    pytestCheckHook
  ];

  buildInputs = [
    libnl
    openssl
  ];

  propagatedBuildInputs = [
    dnsmasq
    iptables
    pbkdf2
    pyric
    roguehostapd
    scapy
  ];

  meta = with lib; {
    description = "The Rogue Access Point Framework";
    homepage = "https://wifiphisher.org";
    license = licenses.gpl3;
  };
}
