{
  lib,
  stdenv,
  fetchFromGitHub,
  boost186,
  cmake,
}:

# fix: src/dht-torture.cpp:36:20: error: 'io_service' has not been declared in 'boost::asio'
# FIXME use boost187
# https://github.com/bittorrent/bootstrap-dht/issues/52
let boost = boost186; in

stdenv.mkDerivation rec {
  pname = "bittorrent-bootstrap-dht";
  version = "unstable-2025-10-11";

  src = fetchFromGitHub {
    owner = "bittorrent";
    repo = "bootstrap-dht";
    # fix: src/main.cpp:51:10: fatal error: boost/uuid/sha1.hpp: No such file or directory
    # https://github.com/bittorrent/bootstrap-dht/pull/53
    rev = "56cc9d6d355522a4c62cc1f8b93f97e753cc8aea";
    hash = "sha256-hQi7aD35danEl51oLX9cEx5k7lJs7ky/Qu3TWxw0/jw=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
  ];

  meta = {
    description = "DHT bootstrap server";
    homepage = "https://github.com/bittorrent/bootstrap-dht";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "bootstrap-dht";
    platforms = lib.platforms.all;
  };
}
