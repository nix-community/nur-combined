{ stdenv, lib, fetchFromGitHub, cmake, boost, openssl, libmysqlclient }:

stdenv.mkDerivation rec {
  pname = "trojan-gfw";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "trojan-gfw";
    repo = "trojan";
    rev = "v${version}";
    sha256 = "fCoZEXQ6SL++QXP6GlNYIyFaVhQ8EWelJ33VbYiHRGw=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost openssl libmysqlclient ];

  cmakeFlags = [
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
  ];

  meta = with lib; {
    description = "An unidentifiable mechanism that helps you bypass GFW.";
    homepage = "https://trojan-gfw.github.io/trojan";
    license = licenses.gpl3;
  };
}
