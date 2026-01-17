{ lib, stdenv, fetchFromGitHub, buildEnv
, asio, boost, check, openssl, cmake
}:

stdenv.mkDerivation rec {
  pname = "mariadb-galera";
  version = "25.3.37";

  src = fetchFromGitHub {
    owner = "codership";
    repo = "galera";
    rev = "release_${version}";
    sha256 = "sha256-u+Nk6Hb6J30sI7fr8saOTrlh7uCsbI8+SgC+iOWlFek=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ asio boost.dev check openssl ];

  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.5" ];

  preConfigure = ''
    # make sure bundled asio cannot be used, but leave behind license, because it gets installed
    rm -r asio/{asio,asio.hpp}
  '';

  postInstall = ''
    # for backwards compatibility
    mkdir $out/lib/galera
    ln -s $out/lib/libgalera_smm.so $out/lib/galera/libgalera_smm.so
  '';

  env.NIX_CFLAGS_COMPILE = toString [
    "-std=c++11"
  ];

  meta = {
    description = "Galera 3 wsrep provider library";
    homepage = "https://galeracluster.com/";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.all;
  };
}
