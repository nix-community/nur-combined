{ lib, stdenv, fetchFromGitHub, cmake, boost, openssl }:

stdenv.mkDerivation rec {
  pname = "opcua-stack";
  version = "3.8.1";

  src = fetchFromGitHub {
    owner = "ASNeG";
    repo = "OpcUaStack";
    rev = version;
    hash = "sha256-czpuuT9DeZaYo2Q8Y/vW1kAsIiFhRDSKwVBUcFgb9iQ=";
  };

  sourceRoot = "${src.name}/src";

  nativeBuildInputs = [ cmake ];

  buildInputs = [ boost openssl ];

  meta = with lib; {
    description = "Open Source OPC UA Application Server and OPC UA Client/Server C++ Libraries";
    homepage = "https://asneg.github.io/projects/opcuastack";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
