{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "boost_unordered";
  version = "1.85.1";

  src = fetchFromGitHub {
    owner = "MikePopoloski";
    repo = "boost_unordered";
    rev = "v${version}";
    hash = "sha256-II3LhaZTAmqn0xcWuSF01czy/IGobvpiGAgZ4EjJ6aY=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUS_INCLUDE_TESTS=OFF" ];

  patches = [ ./cmake_install_rules.patch ];

  meta = with lib; {
    description = "Standalone version of the boost::unordered library";
    homepage = "https://github.com/MikePopoloski/boost_unordered";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
