{ stdenv
, fetchFromGitHub
, cmake
, net-snmp
, openssl
, ...
}:

stdenv.mkDerivation {
  name = "udpgen";

  src = fetchFromGitHub {
    owner = "OpenNMS";
    repo = "udpgen";
    rev = "cf8d3cb5dd19e12350e862b98f86b22ea517ff87";
    hash = "sha256-JeiN9yliRLZZorkUtBBu7hbuDbFYAwyheYIkXJCIdWo=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    net-snmp
    openssl
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-unused-result";

  installPhase = ''
    mkdir -p $out/bin/
    cp udpgen $out/bin/
  '';
}

