{ sources, stdenv, lib, cmake, boost, openssl, libmysqlclient }:

stdenv.mkDerivation rec {
  inherit (sources.trojan) pname version src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost openssl libmysqlclient ];

  cmakeFlags = [
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
  ];

  meta = with lib; {
    description = "An unidentifiable mechanism that helps you bypass GFW";
    homepage = "https://trojan-gfw.github.io/trojan";
    license = licenses.gpl3;
  };
}
