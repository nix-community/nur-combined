{ lib, python3Packages, fetchFromGitHub }:

let
  version = "0.16.1";
  pname = "vpn-slice";
in python3Packages.buildPythonApplication rec {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "dlenski";
    repo = pname;
    rev = "v${version}";
    sha256 = "16shhgypw78d9982r7v293h8fbmpl4wvjb6076w66baincn599ag";
  };

  propagatedBuildInputs = with python3Packages; [ dnspython setproctitle ];

  meta = with lib; {
    description = "vpnc-script replacement for easy and secure split-tunnel VPN setup";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
