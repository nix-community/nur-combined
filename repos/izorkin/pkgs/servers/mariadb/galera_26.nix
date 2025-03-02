{ lib, stdenv, fetchFromGitHub, buildEnv
, asio, boost, check, openssl, cmake
}:

stdenv.mkDerivation rec {
  pname = "mariadb-galera";
  version = "26.4.21";

  src = fetchFromGitHub {
    owner = "codership";
    repo = "galera";
    rev = "release_${version}";
    hash = "sha256-mXnQOs2WNdXORBqcfQPgDoJjbyrpypGDOkgP09JZ9Qo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ asio boost.dev check openssl ];

  preConfigure = ''
    # make sure bundled asio cannot be used, but leave behind license, because it gets installed
    rm -r asio/{asio,asio.hpp}
  '';

  postInstall = ''
    # for backwards compatibility
    mkdir $out/lib/galera
    ln -s $out/lib/libgalera_smm.so $out/lib/galera/libgalera_smm.so
  '';

  meta = {
    description = "Galera 3 wsrep provider library";
    homepage = "https://galeracluster.com/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.all;
  };
}
