{ stdenv, lib, pkgs, fetchurl,fetchFromGitHub, openssl }:
stdenv.mkDerivation rec {
  pname = "vpn-ws";
  version = "9d0e866";
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "unbit";
    repo = "vpn-ws";
    rev = version;
    sha256 = "0k7338xxvg1k988zz3nb681nsqmfiik9bnkk7jmxjz7j0wfwq8nj";
  };

  patchPhase = ''
    sed -i 's/-Werror//' Makefile
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp vpn-ws vpn-ws-client $out/bin
  '';

  buildInputs = [ openssl.dev ];

  meta = {
    homepage = https://github.com/unbit/vpn-ws;
    description = "A VPN system over websockets";
    license = lib.licenses.mit;
  };
}
